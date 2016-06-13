#!/usr/bin/env bash
#
# EupathDB organism package finalization script
# Keith Hughitt (khughitt@umd.edu)
# 2015/01/29
#
##############################################################################

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

cd $output_dir/$organismdb_name

# Add orgdb and txdb dependencies to NAMESPACE
sed -i "s/GO.db/GO.db,${orgdb_name},${txdb_name}/" DESCRIPTION

#
# Generate organismdb README.md
#
cat << EOF > README.md
# $organismdb_name

Meta-package linking species-specific annotations for *$description*, based on
annotated genes from [$db_name $db_version]($db_url).

This package was generated using the tools from
[https://github.com/elsayed-lab/eupathdb-organismdb](github.com/eupathdb-organismdb).

Installation
------------

You can install the latest version from Github using:

\`\`\` r
library('devtools')
install_github('elsayed-lab/$organismdb_name')
\`\`\`

Usage
-----

This package is based on the Bioconductor
[AnnotationDbi](http://www.bioconductor.org/packages/release/bioc/html/AnnotationDbi.html)
interface. As such, the methods for interacting with this package are similar
to the ways one can interact with other commonly-used annotation packages such as
[Homo.sapiens](http://bioconductor.org/packages/release/data/annotation/html/Homo.sapiens.html).

Example usage:

\`\`\`r
library($organismdb_name)

# list available fields to query
columns($organismdb_name)

# get first 10 genes
gene_ids = head(keys($organismdb_name), 10)

# fields of interest
fields = c('CHROMOSOME', 'GENENAME', 'TXSTRAND', 'TXSTART', 'TXEND')

# Gene info
annotations = AnnotationDbi::select($organismdb_name, 
                                    keys=gene_ids, 
                                    keytype='GID', 
                                    columns=fields)
head(annotations)

# KEGG pathways
kegg_mapping = AnnotationDbi::select($organismdb_name, keys=gene_ids, 
                                     keytype='GID',
                                     columns=c('GO', 'TERM', 'ONTOLOGYALL'))
head(kegg_mapping)
\`\`\`

For more information, check out the [AnnotationDbi - Introduction to Annotation
packages vignette](http://www.bioconductor.org/packages/release/bioc/vignettes/AnnotationDbi/inst/doc/IntroToAnnotationPackages.pdf).

Additional resources that may be helpful:

1. http://www.bioconductor.org/help/workflows/annotation-data/
2. http://bioconductor.org/packages/release/bioc/html/OrganismDbi.html
3. http://training.bioinformatics.ucdavis.edu/docs/2012/05/DAV/lectures/annotation/annotation.html
4. http://bioconductor.org/packages/release/data/annotation/html/Homo.sapiens.html
EOF

# Install OrganismDb
echo "Installing OrganismDb..."
cd $cwd
R CMD INSTALL $output_dir/$organismdb_name

