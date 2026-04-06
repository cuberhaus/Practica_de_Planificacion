.PHONY: help dev install clean zip

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*##"}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

dev: ## Launch the SvelteKit web app (installs deps if needed)
	@cd web && [ -d node_modules ] || npm install
	cd web && npm run dev

install: ## Install web dependencies
	cd web && npm install

Sara_Buceta_Pol_Casacuberta_Alejandro_Espinosa.zip: src.zip practica_de_planificacion.pdf ## Build submission zip
	zip -r Sara_Buceta_Pol_Casacuberta_Alejandro_Espinosa.zip $^

src.zip: Basico/ Extension_1/ Extension_2/ Extension_3/ Extension_4/ Extra_2/ README.md
	zip -r src.zip $^

clean: ## Remove generated zips
	rm -f Sara_Buceta_Pol_Casacuberta_Alejandro_Espinosa.zip src.zip
