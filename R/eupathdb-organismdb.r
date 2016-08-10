## The following was taken from ggplot2's ggplot2.r
## I presume it is a blanket importer cue for roxygen2 to add
## import statements to the NAMESPACE file so that when ggplot2 is used
## it will ensure that these libraries are available.
## I checked the roxygen documentation and it appears that
## imports are saved as the exclusive set, as a result repeating these
## at each function declaration serves to make explicit what each function
## requires while not (I think) adding excessive cruft to the NAMESPACE

## #' @import scales grid gtable
## #' @importFrom plyr defaults
## #' @importFrom stats setNames
## NULL

#' eupathdb-organismdb: Make annotation packages for Tryps easier!
#'
#' This should bring together the annotation data at the TriTrypDB, gene ontology data, and KEGG.
#' Soon other datatypes should follow, especially the COG data.
#'
#' @docType package
#' @name eupathdb-organismdb
#' @import utils
#' @import methods
#' @import magrittr
NULL

#' Pipe operator
#'
#' Shamelessly scabbed from Hadley: https://github.com/sckott/analogsea/issues/32
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL
