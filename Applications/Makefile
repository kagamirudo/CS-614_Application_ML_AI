# Applications: Apollo + scratch/click restoration setup
.PHONY: apollo-kernel apollo-clean apollo-clean-all audiofix-kernel audiofix-clean audiofix-clean-all help

help:
	@echo "Applications — make apollo-kernel | apollo-clean | apollo-clean-all"
	@echo "               make audiofix-kernel | audiofix-clean | audiofix-clean-all"

apollo-kernel:
	@bash ./create_apollo_kernel.sh

apollo-clean:
	@bash ./clean_apollo_env.sh

apollo-clean-all:
	@bash ./clean_apollo_env.sh --all

audiofix-kernel:
	@bash ./create_audiofix_kernel.sh

audiofix-clean:
	@bash ./clean_audiofix_env.sh

audiofix-clean-all:
	@bash ./clean_audiofix_env.sh --all
