###############################################################################
#
# TriTrypDB OrganismDB package generation
#
# This script uses resources from TriTrypDB to generate a Bioconductor
# OrganismDB annotation package.
#
# Note that in order for this to work properly, TranscriptDB and OrgDB
# databases must first be generated using the other build_xx.r scripts.
# 
###############################################################################
library(yaml)
library(GenomicFeatures)
library(OrganismDbi)
library(org.LmjF.tritryp.db)
library(TxDb.LmajorFriedlin.tt9.knownGene)

options(stringsAsFactors=FALSE)

#
# MAIN
#
# Load settings
settings = yaml.load_file('config.yaml')

# Create build directory
if (!file.exists(settings$build_dir)) {
    dir.create(settings$build_dir)
}
build_basename = file.path(settings$build_dir,
                            sub('.gff', '', basename(settings$gff)))

# mapping
graph_data = list(
    join1=c(GO.db='GOID', org.LmjF.tritryp.db='GO'),
    join2=c(org.LmjF.tritryp.db='GID', TxDb.LmajorFriedlin.tt9.knownGene='GENEID')
)

makeOrganismPackage(
    pkgname=settings$organismdb_name,
    graphData=graph_data,
    organism=paste(settings$genus, settings$species),
    version=settings$tritrypdb_version,
    maintainer=settings$maintainer,
    author=settings$author,
    destDir='.',
    license='Artistic-2.0'
)