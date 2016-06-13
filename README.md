EuPathDB OrganismDB package generator
=====================================

Overview
--------

This script uses resources from [EuPathDB](http://www.eupathdb.org/eupathdb/)
databases such as [TriTrypDB](http://tritrypdb.org/tritrypdb/) and
[ToxoDB](http://toxodb.org/toxo/) to generate a Bioconductor Organism
annotation packages.

Requirements
------------

For this script to work, you must have installed the following R libraries:

- [yaml](http://cran.r-project.org/web/packages/yaml/index.html)
- [rtracklayer](http://www.bioconductor.org/packages/release/bioc/html/rtracklayer.html)
- [GenomicFeatures](http://www.bioconductor.org/packages/release/bioc/html/GenomicFeatures.html)
- [OrganismDbi](http://www.bioconductor.org/packages/release/bioc/html/OrganismDbi.html)

Usage
-----

The use this script, begin by modifying or creating a new YAML configuration
file specifying the details for the species you wish to process. Examples
configuration files for several species can be found in the `settings` folder.
Next, modify the `build_xx.r` scripts to point to the setting file you wish you
use.

Note that at present, you may also need to edit the `build_orgdb.r` script
to enable it to properly map KEGG identifiers to EuPathDB identifiers for your
target species. In the future, this will be generalized if possible so that
this can be handled via config settings.

Now we are ready to construct the OrgDb and TranscriptDb packages:

```sh
$ Rscript build_orgdb.r
$ Rscript build_txdb.r
$ sh prepare_dbs.sh
```

This will generate OrgDb and TranscriptDb packages in the current working
directory. The `prepare_dbs.sh` script performs some post-processing to replace
default names with desired before generating the final Organism package.

The final step then is to construct an OrganismDb package. In order to proceed,
however, you must first install the OrgDb and TranscriptDb packages generated
above.

You can then use the `install.packages` command to install the annotations
database locally, e.g.:

```r
install.packages("./org.LmjF.tritryp.db", repos=NULL)
```

Finally, the Organism package can be constructed using the following command:

```sh
$ Rscript build_organismdb.r
```

All done!

Getting Help
------------

This script has been designed to work with any EuPathDB organisms for
which both GFF and gene TXT annotations are available. Currently, however, it
has only been tested on L. major Friedlin annotations. If you encounter issues
using it for your organism of interest, feel free to submit fixes via pull
requests, or report the problem as an issue.

For questions, feel free to contact me at [khughitt@umd.edu](khughitt@umd.edu).

Generated Packages
------------------

Below are a list of packages generated for serveral species using these
scripts:

- TODO

See Also
--------

- [AnnotationForge - Making Organism packages](http://www.bioconductor.org/packages/release/bioc/vignettes/AnnotationForge/inst/doc/MakingNewOrganismPackages.html)
- [Bioconductor - Making and Utilizing TxDb Objects](http://www.bioconductor.org/packages/release/bioc/vignettes/GenomicFeatures/inst/doc/GenomicFeatures.pdf)
- [Bioconductor - Making an OrganismDb package](http://www.bioconductor.org/help/workflows/annotation/#Making-an-OrganismDb-package)
- [Bioconductor - AnnotationForge](http://www.bioconductor.org/packages/release/bioc/html/AnnotationForge.html)
- [Bioconductor - GO.db](http://www.bioconductor.org/packages/release/data/annotation/html/GO.db.html)
- [Bioconductor - OrganismDbi](http://www.bioconductor.org/packages/release/bioc/html/OrganismDbi.html)

TODO
----

1. Create vignettes
2. Add UTRs
3. Fix DBSCHEMA information
4. Add additional metadata from TriTrypDB, e.g.:
    - Gene Type
    - NonSyn/Syn SNP Ratio
    - Isoelectric Point
    - etc.


