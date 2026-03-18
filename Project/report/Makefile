TEX = pdflatex
BIB = bibtex
MAIN = main
CTAN = https://mirrors.ctan.org/macros/latex/contrib/IEEEtran

.PHONY: pdf clean

pdf: $(MAIN).pdf

IEEEtran.cls:
	wget -q "$(CTAN)/IEEEtran.cls" -O $@

IEEEtran.bst:
	wget -q "$(CTAN)/bibtex/IEEEtran.bst" -O $@

$(MAIN).pdf: $(MAIN).tex references.bib IEEEtran.cls IEEEtran.bst
	$(TEX) -interaction=nonstopmode $(MAIN)
	$(BIB) $(MAIN)
	$(TEX) -interaction=nonstopmode $(MAIN)
	$(TEX) -interaction=nonstopmode $(MAIN)

clean:
	rm -f $(MAIN).aux $(MAIN).bbl $(MAIN).blg $(MAIN).log $(MAIN).out \
	      $(MAIN).toc $(MAIN).lof $(MAIN).lot $(MAIN).fls \
	      $(MAIN).fdb_latexmk $(MAIN).synctex.gz $(MAIN).nav $(MAIN).snm \
	      $(MAIN).run.xml $(MAIN)-blx.bib IEEEtran.cls IEEEtran.bst
