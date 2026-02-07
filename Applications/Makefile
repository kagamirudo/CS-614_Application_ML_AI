# Applications: Apollo (music restoration) and related setup
.PHONY: apollo-kernel apollo-clean apollo-clean-all help

help:
	@echo "Applications Makefile"
	@echo "  make apollo-kernel     - Create conda env in /opt/apollo-env and register Jupyter kernel 'Python (Apollo)'"
	@echo "  make apollo-clean      - Remove old named env 'apollo' and kernel (after failed/partial install)"
	@echo "  make apollo-clean-all - Same + remove /opt/apollo-env (full cleanup, then re-run apollo-kernel to reinstall)"

apollo-kernel:
	@bash ./create_apollo_kernel.sh

apollo-clean:
	@bash ./clean_apollo_env.sh

apollo-clean-all:
	@bash ./clean_apollo_env.sh --all
