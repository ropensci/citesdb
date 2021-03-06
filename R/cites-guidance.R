#' @title  CITES Trade Database shipment-level guidance
#'
#' @description _This text copied from the supplementary information file
#'   accompanying the full database download from <https://trade.cites.org/>_
#'
#' @section Recommended citation:
#'
#'   UNEP-WCMC (Comps.) 2019. Full CITES Trade Database Download. Version
#'   2019.2. CITES Secretariat, Geneva, Switzerland. Compiled by UNEP-WCMC,
#'   Cambridge, UK. Available at: trade.cites.org.
#'
#' @section Background:
#'
#'   Under Article VIII of the Convention, Parties are required to provide
#'   information regarding their trade in CITES-listed specimens through their
#'   annual reports, and the Secretariat makes this information available
#'   through the CITES Trade Database (trade.cites.org). This database currently
#'   contains over 20 million records of international trade in CITES-listed
#'   species. Parties recognise the importance of these reports as a tool for
#'   monitoring the implementation of the Convention, assessing the
#'   effectiveness of their wildlife management and trade policies, and to
#'   enhance the detection of potentially harmful or illicit trade.
#'
#'   At the 70th meeting of the Standing Committee, Parties agreed that a full
#'   non-aggregated version of the CITES Trade Database should be made available
#'   and updated twice a year. These files represent the periodic release of the
#'   CITES trade data in a shipment-by-shipment format with unique identifiers
#'   replacing confidential permit numbers (see [SC70 Doc
#'   26.2](https://cites.org/sites/default/files/eng/com/sc/70/E-SC70-26-02.pdf
#'   ) and [SC70 Inf.
#'   1](https://cites.org/sites/default/files/eng/com/sc/70/Inf/E-SC70-Inf-01.pdf)
#'    for further background).
#'
#' @section Overview of data:
#'
#'   This zip file contains all trade records (including all historic data)
#'   entered in the CITES Trade Database by 29 January 2019 and extracted at the
#'   shipment level on 30 January 2019. This file is 2019.v2 and replaces
#'   version 2019.v1 which contained some formatting anomalies and strengthens
#'   security.
#'
#'   While the data provided through the search function on the [Web Portal of
#'   the CITES Trade Database](https://trade.cites.org/) are aggregated, the
#'   database contains non-aggregated data. The data provided in this download
#'   is on a per-shipment basis i.e. it provides the relevant information about
#'   each line item in box 7 to 12 of the [CITES
#'   permit](https://www.cites.org/sites/default/files/document/E-Res-12-03-R17.pdf)
#'   (Annex 1, in line with Notification No. 2017/006) in a separate row. Each
#'   csv data file contains 500 thousand rows of data, and files are numbered
#'   chronologically with the earliest trade records in the files with the lower
#'   numbers.
#'
#'   Given their confidential nature, import, export and re-export CITES permit
#'   numbers have been replaced with unique identifiers. This ensures that no
#'   confidential data are made available, whilst still enabling users of the
#'   data to identify instances where the same permit number may have been used
#'   for multiple shipments. The method for generating these unique identifiers
#'   is detailed below.
#'
#'   Subsequent additions to the database will be extracted twice a year and
#'   added as new csv files, which will be detailed with each new release.
#'
#' @section Replacement of the permit number by a unique identifier:
#'
#'   The permit numbers in the download have been replaced with a unique
#'   identification number (‘identifier’). This identifier is a ten character
#'   alpha/numeric string which is built from a cryptographically secure
#'   pseudo-random alpha-numeric string (which is independent of the permit
#'   number), which is then hashed via secure, non-reversible cryptographic hash
#'   function (Secure Hash Algorithm 2, SHA-512 which uses 64-bit words to
#'   construct the hash. SHA-512 is specified in [document FIPF PUB 180-4,
#'   National Institute of Technology
#'   (NIST)](http://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf)). This
#'   process preserves the relationship between exports and re-exports if the
#'   Parties have reported corresponding export and re-export permit numbers.
#'   Permit numbers always retain the same unique identifier in each release.
#'   The same unique identifier is assigned irrespective of whether the permit
#'   number is reported as an import, export or re-export permit.
#'
#' @rdname guidance
#' @name guidance
#' @aliases si supplementary
NULL
