# Applications: Apollo + scratch/click restoration setup
.PHONY: apollo-kernel apollo-clean apollo-clean-all audiofix-kernel audiofix-clean audiofix-clean-all help

help:
	@echo "Applications Makefile"
	@echo "  make apollo-kernel     - Create conda env in /opt/apollo-env and register Jupyter kernel 'Python (Apollo)'"
	@echo "  make apollo-clean      - Remove old named env 'apollo' and kernel (after failed/partial install)"
	@echo "  make apollo-clean-all - Same + remove /opt/apollo-env (full cleanup, then re-run apollo-kernel to reinstall)"
	@echo "  make audiofix-kernel   - Create conda env in /opt/audiofix-env and register Jupyter kernel 'Python (audiofix)' for music.ipynb"
	@echo "  make audiofix-clean    - Remove old 'audiofix' env/kernel (Anaconda) for music.ipynb"
	@echo "  make audiofix-clean-all- Same + remove /opt/audiofix-env (full cleanup, then re-run audiofix-kernel)"

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
