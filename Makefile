.PHONY: clean
VERSION=2016.08
export _R_CHECK_FORCE_SUGGESTS_=FALSE
PKG=eupathdb-organismdb

all: clean reference check build test

install: prereq document
	@echo "Performing R CMD INSTALL hpgltools"
	@cd ../ && R CMD INSTALL $(PKG) && cd $(PKG)

reference:
	@echo "Generating reference manual with R CMD Rd2pdf"
	@rm -f inst/doc/reference.pdf
	@R CMD Rd2pdf . -o inst/doc/reference.pdf

check:
	@echo "Performing check with R CMD check $(PKG)"
	@cd ../ && export _R_CHECK_FORCE_SUGGESTS_=FALSE && R CMD check $(PKG) --no-build-vignettes && cd $(PKG)

build:
	@echo "Performing build with R CMD build $(PKG)"
	@cd ../ && R CMD build $(PKG) && cd $(PKG)

test: install
	@rm -rf tests/testthat/*.rda
	@echo "Running run_tests.R"
	@./run_tests.R

roxygen:
	@echo "Generating documentation with roxygen2::roxygenize()"
	@Rscript -e "roxygen2::roxygenize()"

document:
	@echo "Generating documentation with devtools::document()"
	@Rscript -e "devtools::document()"

vignette:
	@echo "Building vignettes with devtools::build_vignettes()"
	@Rscript -e "devtools::build_vignettes()"

clean_vignette:
	@rm -f inst/doc/* vignettes/*.rda vignettes/*.map vignettes/*.Rdata

vt:	clean_vignette vignette install

clean:
	find . -type f -name '*.Rdata' -exec rm -rf {} ';' 2>/dev/null

prereq:
	Rscript -e "suppressMessages(source('http://bioconductor.org/biocLite.R'));\
bioc_prereq <- c('pasilla','testthat','roxygen2','Biobase','AnnotationForge');\
for (req in bioc_prereq) { if (class(try(suppressMessages(eval(parse(text=paste0('library(', req, ')')))))) == 'try-error') { biocLite(req) } };\
## hahaha looks like lisp!"

update_bioc:
	Rscript -e "source('http://bioconductor.org/biocLite.R'); biocLite(); biocLite('BiocUpgrade');"

update:
	Rscript -e "source('http://bioconductor.org/biocLite.R'); biocLite(); library(BiocInstaller); biocValid()"

## The following should probably be removed as my changes made this into a pure R package with
## functions to handle these tasks rather than handling it via config files and make
%:	%.yaml
	@rm -rf build && mkdir build
	@echo "Generating orgdb package."
	./orgdb.R $*.yaml
	@echo "Finished generating $* orgdb package."
	@echo "Generating TxDb package."
	./txdb.R $*.yaml
	@echo "Finished generating $* txdb package."
	@echo "Installing TxDb and orgdbs."
	./prepare.sh $*.yaml
	@echo "Generating organismDbi package."
	./organismdb.R $*.yaml
	@echo "Finished generating $* organismdb package, installing it."
	./final.sh $*.yaml
	@echo "Installed packages in R."

clean:
	@rm -r build && mkdir build
	@rm -r output && mkdir output

install: orgdb txdb organismdb

orgdb:
	./orgdb.R
txdb:
	./txdb.R
organismdb:
	./prepare.sh
	./organismdb.R
	./final.sh
