# Leishmania.major.Friedlin

Meta-package linking species-specific annotations for *L. major strain Friedlin*, based on
annotated genes from [TriTrypDB 27](http://tritrypdb.org/tritrypdb/).

This package was generated using the tools from
[https://github.com/elsayed-lab/eupathdb-organismdb](github.com/eupathdb-organismdb).

Installation
------------

You can install the latest version from Github using:

``` r
library('devtools')
install_github('elsayed-lab/Leishmania.major.Friedlin')
```

Usage
-----

This package is based on the Bioconductor
[AnnotationDbi](http://www.bioconductor.org/packages/release/bioc/html/AnnotationDbi.html)
interface. As such, the methods for interacting with this package are similar
to the ways one can interact with other commonly-used annotation packages such as
[Homo.sapiens](http://bioconductor.org/packages/release/data/annotation/html/Homo.sapiens.html).

Example usage:

```r
library(Leishmania.major.Friedlin)

# list available fields to query
columns(Leishmania.major.Friedlin)

# get first 10 genes
gene_ids = head(keys(Leishmania.major.Friedlin), 10)

# fields of interest
fields = c('CHROMOSOME', 'GENENAME', 'TXSTRAND', 'TXSTART', 'TXEND')

# Gene info
annotations = AnnotationDbi::select(Leishmania.major.Friedlin, 
                                    keys=gene_ids, 
                                    keytype='GID', 
                                    columns=fields)
head(annotations)

# KEGG pathways
kegg_mapping = AnnotationDbi::select(Leishmania.major.Friedlin, keys=gene_ids, 
                                     keytype='GID',
                                     columns=c('GO', 'TERM', 'ONTOLOGYALL'))
head(kegg_mapping)
```

For more information, check out the [AnnotationDbi - Introduction to Annotation
packages vignette](http://www.bioconductor.org/packages/release/bioc/vignettes/AnnotationDbi/inst/doc/IntroToAnnotationPackages.pdf).

Additional resources that may be helpful:

1. http://www.bioconductor.org/help/workflows/annotation-data/
2. http://bioconductor.org/packages/release/bioc/html/OrganismDbi.html
3. http://training.bioinformatics.ucdavis.edu/docs/2012/05/DAV/lectures/annotation/annotation.html
4. http://bioconductor.org/packages/release/data/annotation/html/Homo.sapiens.html
