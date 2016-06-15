#!/usr/bin/env Rscript
###############################################################################
##
## EuPathDB TxDB package generation
##
## This script uses resources from EuPathDB to generate a Bioconductor
## Transcript annotation package.
##
###############################################################################
suppressMessages(library(yaml))
suppressMessages(library(rtracklayer))
suppressMessages(library(GenomicFeatures))

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

#
# chromosome info
#
# NOTE: In the future, perhaps it would be better instead to first filter the
# source GFF and remove all non-standard entries?
#
# non-standard types:
#
# apicoplast_chromosome (T. gondii ME49)
# random_sequence       (T. brucei TREU927)
# geneontig             (T. brucei TREU927)
#
gff = import.gff3(settings$gff)
ch = gff[gff$type %in% c('apicoplast_chromosome', 'chromosome', 'contig',
                         'geneontig', 'random_sequence', 'supercontig')]

#genes = gff[gff$type == 'gene']
#gene_ch = unique(as.character(chrom(genes)))

chrom_info = data.frame(
    chrom=ch$ID,
    length=as.numeric(ch$size),
    is_circular=NA
)

# 2015/06/16 Switching backt o mRNA entries to construct TxDb -- database is
# intended for mRNAs so ncRNAs will be handled separately.

#txdb = makeTranscriptDbFromGFF(
txdb = makeTxDbFromGFF(
    file=settings$gff,
    format='gff3',
    chrominfo=chrom_info,
    ## exonRankAttributeName=NA,
    dataSource=sprintf('%s %s', settings$db_name, settings$db_version),
    organism=paste(settings$genus, settings$species)
)


# Save transcript database
short_name = paste0(substring(tolower(settings$genus), 1, 1), settings$species)
saveDb(txdb, file=file.path(build_dir, sprintf("%s.sqlite", short_name)))

# R package versions must be of the form "x.y"
db_version = paste(settings$db_version, '0', sep='.')

# Build TxDB package
makeTxDbPackage(
    txdb,
    destDir=settings$output_dir,
    version=db_version,
    maintainer=settings$maintainer,
    author=settings$author,
    license='Artistic-2.0'
)

