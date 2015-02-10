# variables
THESIS := thesis
DRAFT := draft
LATEX := xelatex
LATEXOPTS := pdf
TYPESETS := ./typesetting
FONTDIR := ~/.fonts
TEXMF := ~/texmf

# latexmk is necessary for correct building
# and we want it to run every time
.PHONY: $(THESIS).pdf all clean draft reset

# MAIN LATEXMK RULES 
all: $(THESIS).pdf

$(THESIS).pdf: $(THESIS).tex 
	latexmk -$(LATEXOPTS) -$(LATEX) --halt-on-error -use-make $(THESIS).tex

# make draft using just what is in draft.tex
draft: $(DRAFT).pdf

$(DRAFT).pdf: $(DRAFT).tex
	latexmk -$(LATEXOPTS) -$(LATEX) --halt-on-error -use-make $(DRAFT).tex

#packages:
#	cp $(TYPESETS)/texmf/* $(TEXMF)
#	#export TEXINPUTS=.:./typesetting/texmf
#
#fonts:
#	cp $(TYPESETS)/fonts/* $(FONTDIR)
#
#install: packages fonts
#	touch $(TYPESETS)/install_marker

#(echo t.svg --export-pdf=t.pdf;
#echo u.svg --export-pdf=u.pdf) |
#  DISPLAY= inkscape --shell


clean:
	latexmk -c
	-@rm -f -v *pdfsync *synctex.gz *.fls *.log *.bbl

reset:
	latexmk -CA
	-@rm -f -v *pdfsync *synctex.gz *.fls