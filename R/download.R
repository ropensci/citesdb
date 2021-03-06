#' Download the CITES database to your local computer
#'
#' This command downloads the CITES shipments database and populates a local
#' database. The download is large (~158 MB), and the database will be ~5 GB
#' on disk. During import 10 GB of disk space may be used temporarily.
#'
#' The database is stored by default under [rappdirs::user_data_dir()], or its
#' location can be set with the environment variable `CITES_DB_DIR`.
#'
#' @param tag What release tag of data to download. Defaults to the most recent.
#' Releases are expected to come twice per year. See all releases at
#' <https://github.com/ropensci/citesdb/releases>.
#' @param destdir Where to download the compressed file.
#' @param cleanup Whether to delete the compressed file after loading into the database.
#' @param verbose Whether to display messages and download progress
#'
#' @return NULL
#' @export
#' @importFrom DBI dbRemoveTable dbExistsTable dbCreateTable dbExecute
#'   dbWriteTable dbListTables
#' @importFrom R.utils gunzip
#' @importFrom dplyr %>%
#'
#' @examples
#' \donttest{
#' \dontrun{
#' cites_db_download()
#' }
#' }
cites_db_download <- function(tag = NULL, destdir = tempdir(),
                              cleanup = TRUE, verbose = interactive()) {

  if (verbose) message("Downloading data...\n")
  zfile <- get_gh_release_file("ropensci/citesdb",
    tag_name = tag,
    destdir = destdir, verbose = verbose
  )
  ver <- attr(zfile, "ver")
  if (verbose) message("Decompressing and building local database...\n")
  temp_tsv <- tempfile(fileext = ".tsv")
  gunzip(zfile, destname = temp_tsv, overwrite = TRUE, remove = cleanup)

  # for (tab in dbListTables(cites_db())) {
  #   dbRemoveTable(cites_db(), tab)
  # }
  # cites_disconnect()
  # invisible(cites_db())
  unlink(cites_path(), recursive = TRUE, force = TRUE, expand = FALSE)

  tblname <- "cites_shipments"

  try(dbRemoveTable(cites_db(read_only = FALSE), tblname), silent = TRUE)
  cites_disconnect()
  dbCreateTable(cites_db(read_only = FALSE), tblname, fields = cites_field_types)

  suppressMessages(
    dbExecute(
      cites_db(),
      paste0(
        "COPY ", tblname, " FROM '",
        temp_tsv,
        "' ( DELIMITER '\t', HEADER 1, NULL 'NA' )"
      )
    )
  )
  cites_disconnect()
  dbWriteTable(cites_db(read_only = FALSE), "cites_status", make_status_table(version = ver),
    overwrite = TRUE
  )

  load_citesdb_metadata()

  file.remove(temp_tsv)

  update_cites_pane()

  cites_status()
  cites_disconnect()
}

cites_field_types <- c(
  Id = "STRING",
  Year = "INTEGER",
  Appendix = "STRING",
  Taxon = "STRING",
  Class = "STRING",
  Order = "STRING",
  Family = "STRING",
  Genus = "STRING",
  Term = "STRING",
  Quantity = "DOUBLE PRECISION",
  Unit = "STRING",
  Importer = "STRING",
  Exporter = "STRING",
  Origin = "STRING",
  Purpose = "STRING",
  Source = "STRING",
  Reporter.type = "STRING",
  Import.permit.RandomID = "STRING",
  Export.permit.RandomID = "STRING",
  Origin.permit.RandomID = "STRING"
)

#' @importFrom DBI dbGetQuery
make_status_table <- function(version) {
  sz <- sum(file.info(list.files(cites_path(),
                                 all.files = TRUE,
                                 recursive = TRUE,
                                 full.names = TRUE))$size)
  class(sz) <- "object_size"
  data.frame(
    time_imported = Sys.time(),
    version = version,
    number_of_records = formatC(
      DBI::dbGetQuery(cites_db(),
                      "SELECT COUNT(*) FROM cites_shipments;")[[1]],
      format = "d", big.mark = ","),
    size_on_disk = format(sz, "auto"),
    location_on_disk = cites_path()
  )
}

#' @importFrom httr GET stop_for_status content accept write_disk progress
#' @importFrom purrr keep
get_gh_release_file <- function(repo, tag_name = NULL, destdir = tempdir(),
                                overwrite = TRUE, verbose = interactive()) {
  releases <- GET(
    paste0("https://api.github.com/repos/", repo, "/releases")
  )
  stop_for_status(releases, "finding releases")

  releases <- content(releases)

  if (is.null(tag_name)) {
    release_obj <- releases[1]
  } else {
    release_obj <- purrr::keep(releases, function(x) x$tag_name == tag_name)
  }

  if (!length(release_obj)) stop("No release tagged \"", tag_name, "\"")

  if (release_obj[[1]]$prerelease) {
    message("This is pre-release/sample data! It has not been cleaned or validated.")  #nolint
  }

  download_url <- release_obj[[1]]$assets[[1]]$url
  filename <- basename(release_obj[[1]]$assets[[1]]$browser_download_url)
  out_path <- normalizePath(file.path(destdir, filename), mustWork = FALSE)
  response <- GET(
    download_url,
    accept("application/octet-stream"),
    write_disk(path = out_path, overwrite = overwrite),
    if (verbose) progress()
  )
  stop_for_status(response, "downloading data")

  attr(out_path, "ver") <- release_obj[[1]]$tag_name
  return(out_path)
}

#' @importFrom utils read.table
load_citesdb_metadata <- function() {
  tsvs <- list.files(system.file("extdata", package = "citesdb"),
                     pattern = "\\.tsv$", full.names = TRUE
  )
  tblnames <- tools::file_path_sans_ext(basename(tsvs))
  for (i in seq_along(tsvs)) {
    suppressMessages(dbWriteTable(cites_db(), tblnames[i],
                                  read.table(
                                    tsvs[i],
                                    stringsAsFactors = FALSE, sep = "\t",
                                    header = TRUE, quote = "\""
                                  ),
                                  overwrite = TRUE
    ))
  }
}
