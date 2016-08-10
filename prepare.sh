#!/usr/bin/env bash
#
# EuPathDB organism package generation post-processing
# Keith Hughitt (khughitt@umd.edu)
# 2015/01/29
#
# This package applies some post-processing to the output of the previous R
# scripts, renaming packages and fixing metadata fields.
##############################################################################

# TODO: Add EuPathDB DBSCHEMA?
# https://github.com/genome-vendor/r-bioc-annotationdbi/tree/master/inst/DBschemas

# YAML parser
# http://stackoverflow.com/questions/5014632/how-can-i-parse-a-yaml-file-from-a-linux-shell-script
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

config_file=${1-"config.yaml"}
# load configuration
eval $(parse_yaml ${config_file})

# current directory
cwd=$(pwd)

#
# OrgDB
#

# old package name (e.g. "org.Lmajor.eg.db")
printf -v orgdb_name_old 'org.%s%s.eg.db' ${genus:0:1} ${species}

echo "Processing $orgdb_name_old..."

# name without the .db suffix
orgdb_name_short_old=${orgdb_name_old/.db/}
orgdb_name_short=${orgdb_name/.db/}

# rename and enter directory
mv $output_dir/$orgdb_name_old $output_dir/$orgdb_name
cd $output_dir/$orgdb_name

# Fix DESCRIPTION
sed -i "s/$orgdb_name_old/$orgdb_name/g" DESCRIPTION
sed -i "s/species:.*/species: $description/g" DESCRIPTION
sed -i "s/Entrez/$db_name/g" DESCRIPTION

# Fix NAMESPACE
sed -i "s/$orgdb_name_short_old/$orgdb_name_short/g" NAMESPACE

# Fix sqlite database
dbpath=inst/extdata/${orgdb_name_short}.sqlite
mv inst/extdata/${orgdb_name_short_old}.sqlite $dbpath

chmod +w $dbpath
sqlite3 $dbpath "UPDATE metadata SET value=\"$description\" WHERE name='SPECIES';"
chmod -w $dbpath

# Fix manual pages
for suffix in "BASE.Rd" "ORGANISM.Rd" "_dbconn.Rd"; do
    mv man/${orgdb_name_short_old}${suffix} man/${orgdb_name_short}${suffix}
    sed -i "s/$orgdb_name_short_old/$orgdb_name_short/g" man/${orgdb_name_short}${suffix}
done

# Fix zzz.R
sed -i "s/$orgdb_name_short_old/$orgdb_name_short/g" R/zzz.R

#
# Generate OrgDb README.md
#
cat << EOF > "${cwd}/output/${orfdb_name}/README.md"
# $orgdb_name

Genome-wide annotation package for *$description*, based on
annotations from [$db_name $db_version]($db_url).

This package was generated using the tools from
[https://github.com/elsayed-lab/eupathdb-organismdb](github.com/eupathdb-organismdb).

Installation
------------

You can install the latest version from Github using:

\`\`\` r
library('devtools')
install_github('elsayed-lab/$orgdb_name')
\`\`\`

Usage
-----

This package is based on the Bioconductor
[AnnotationDbi](http://www.bioconductor.org/packages/release/bioc/html/AnnotationDbi.html)
interface. As such, the methods for interacting with this package are similar
to the ways one can interact with other commonly-used annotation packages such as
[org.Hs.eg.db](http://www.bioconductor.org/packages/release/data/annotation/html/org.Hs.eg.db.html).

Example usage:

\`\`\`r
library($orgdb_name)

# list available fields to query
columns($orgdb_name)

# get first 10 genes
gene_ids = head(keys($orgdb_name), 10)

# gene names and descriptions
annotations = AnnotationDbi::select($orgdb_name,
                                    keys=gene_ids,
                                    keytype='GID',
                                    columns=c('CHROMOSOME', 'GENENAME'))
head(annotations)

# GO terms
go_terms = AnnotationDbi::select($orgdb_name,
                                 keys=gene_ids,
                                 keytype='GID',
                                 columns=c('GO', 'ONTOLOGYALL'))
head(go_terms)

# KEGG pathways
kegg_paths = AnnotationDbi::select($orgdb_name,
                                   keys=gene_ids,
                                   keytype='GID',
                                   columns=c('KEGG_NAME', 'KEGG_PATH'))
head(kegg_paths)
\`\`\`

For more information, check out the [AnnotationDbi - Introduction to Annotation
packages vignette](http://www.bioconductor.org/packages/release/bioc/vignettes/AnnotationDbi/inst/doc/IntroToAnnotationPackages.pdf).

Additional resources that may be helpful:

1. http://www.bioconductor.org/help/workflows/annotation-data/
2. http://www.bioconductor.org/packages/release/data/annotation/html/org.Hs.eg.db.html
3. http://training.bioinformatics.ucdavis.edu/docs/2012/05/DAV/lectures/annotation/annotation.html
EOF

cd $cwd

#
# TranscriptDB
#
printf -v txdb_name_old 'TxDb.%s%s.%s.%s' ${genus:0:1} ${species} ${db_name} ${db_version}
echo "Processing $txdb_name_old..."

mv $output_dir/$txdb_name_old $output_dir/$txdb_name
cd $output_dir/$txdb_name

# Fix DESCRIPTION
sed -i "s/$txdb_name_old/$txdb_name/g" DESCRIPTION
sed -i "s/species:.*/species: $description/g" DESCRIPTION

# Fix NAMESPACE
sed -i "s/$txdb_name_old/$txdb_name/g" NAMESPACE

# Fix sqlite database
dbpath=inst/extdata/${txdb_name}.sqlite
mv inst/extdata/${txdb_name_old}.sqlite $dbpath

# Fix Manual pages
sed -i "s/$txdb_name_old/$txdb_name/g" man/package.Rd

#
# Generate TxDb README.md
#
cat << EOF > "${cwd}/output/${txdb_name}/README.md"
# $txdb_name

Transcript annotation package for *$description*, based on
annotated genes from [$db_name $db_version]($db_url).

This package was generated using the tools from
[https://github.com/elsayed-lab/eupathdb-organismdb](github.com/eupathdb-organismdb).

Installation
------------

You can install the latest version from Github using:

\`\`\` r
library('devtools')
install_github('elsayed-lab/$txdb_name')
\`\`\`

Usage
-----

This package is based on the Bioconductor
[AnnotationDbi](http://www.bioconductor.org/packages/release/bioc/html/AnnotationDbi.html)
interface. As such, the methods for interacting with this package are similar
to the ways one can interact with other commonly-used annotation packages such as
[TxDb.Hsapiens.UCSC.hg19.knownGene](http://www.bioconductor.org/packages/release/data/annotation/html/TxDb.Hsapiens.UCSC.hg19.knownGene.html).

Example usage:

\`\`\`r
library($txdb_name)

# list available fields to query
columns($txdb_name)

# get first 10 genes
gene_ids = head(keys($txdb_name), 10)

# gene coordinates and strand
genes = AnnotationDbi::select($txdb_name,
                              keys=gene_ids,
                              keytype='GENEID',
                              columns=c('TXSTART', 'TXEND', 'TXSTRAND'))

head(genes)
\`\`\`

For more information, check out the [AnnotationDbi - Introduction to Annotation
packages vignette](http://www.bioconductor.org/packages/release/bioc/vignettes/AnnotationDbi/inst/doc/IntroToAnnotationPackages.pdf).

Additional resources that may be helpful:

1. http://www.bioconductor.org/help/workflows/annotation-data/
2. http://www.bioconductor.org/packages/release/data/annotation/html/TxDb.Hsapiens.UCSC.hg19.knownGene.html
3. http://training.bioinformatics.ucdavis.edu/docs/2012/05/DAV/lectures/annotation/annotation.html
EOF

# Install OrgDB and TxDb
echo "Installing databases"
cd $cwd

R CMD INSTALL ${output_dir}/${orgdb_name}
R CMD INSTALL ${output_dir}/${txdb_name}

echo "Done!"
