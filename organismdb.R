#!/usr/bin/env Rscript
###############################################################################
##
## TriTrypDB OrganismDB package generation
##
## This script uses resources from TriTrypDB to generate a Bioconductor
## OrganismDB annotation package.
##
## Note that in order for this to work properly, TranscriptDB and OrgDB
## databases must first be generated using the other build_xx.r scripts.
##
###############################################################################
suppressMessages(library(yaml))
suppressMessages(library(GenomicFeatures))
suppressMessages(library(OrganismDbi))

options(stringsAsFactors=FALSE)

config_file <- "config.yaml"
args <- commandArgs(TRUE)
if (length(args) > 0) {
    config_file <- args[1]
} else {
    message("Defaulting to the configuration in 'config.yaml'.")
}

#
# MAIN
#
# Load settings
settings = yaml.load_file(config_file)

build_dir = file.path(settings$build_dir,
                      paste0(R.Version()$major,  '.', R.Version()$minor))

# Create build directory
if (!file.exists(build_dir)) {
    dir.create(build_dir)
}
build_basename = file.path(build_dir,
                            sub('.gff', '', basename(settings$gff)))

# Load organism-specific packages
library(settings$orgdb_name, character.only=TRUE)
library(settings$txdb_name,  character.only=TRUE)

# mapping
graph_data = list(
    join1=c(GO.db='GOID', orgdb='GO'),
    join2=c(orgdb='GID',  txdb='GENEID')
)

names(graph_data$join1) = c('GO.db', settings$orgdb_name)
names(graph_data$join2) = c(settings$orgdb_name, settings$txdb_name)

# R package versions must be of the form "x.y"
db_version = paste(settings$db_version, '0', sep='.')

makeOrganismPackage(
    pkgname=settings$organismdb_name,
    graphData=graph_data,
    organism=paste(settings$genus, settings$species),
    version=db_version,
    maintainer=settings$maintainer,
    author=settings$author,
    destDir=settings$output_dir,
    license='Artistic-2.0'
)
