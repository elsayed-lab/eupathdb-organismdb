.PHONY: clean

%:	%.yaml
	@rm -r build && mkdir build
	./orgdb.R $*.yaml
	@echo "Finished generating $* orgdb package."
	./txdb.R $*.yaml
	@echo "Finished generating $* txdb package."
	./prepare.sh $*.yaml
	./organismdb.R $*.yaml
	@echo "Finished generating $* organismdb package."
	./final.sh $*.yaml
	@echo "Installed packages in R."

clean:
	@rm -r build && mkdir build

install: orgdb txdb organismdb

orgdb:
	./build_orgdb.R
txdb:
	./build_txdb.R
organismdb:
	./prepare_dbs.sh
	./build_organismdb.R
	./sh finalize.sh
