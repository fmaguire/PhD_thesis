# variables

THESIS := thesis
LATEX := xelatex
LATEXOPTS := pdf
TYPESETS := ./typesetting
FONTDIR := ~/.fonts
TEXMF := ~/texmf

# latexmk is necessary for correct building
# and we want it to run every time
.PHONY: $(THESIS).pdf all clean

# default make 
all: $(THESIS).pdf

# MAIN LATEXMK RULES
# -pdf tells latexmk to generate a pdf directly
# -pdflatex="xelatex" tell latexmk to use xelatex backend

$(THESIS).pdf: $(THESIS).tex 
	latexmk -$(LATEXOPTS) -$(LATEX) --halt-on-error -use-make $(THESIS).tex

#packages:
#	cp $(TYPESETS)/texmf/* $(TEXMF)
#	#export TEXINPUTS=.:./typesetting/texmf
#
#fonts:
#	cp $(TYPESETS)/fonts/* $(FONTDIR)
#
#install: packages fonts
#	touch $(TYPESETS)/install_marker

clean:
	latexmk -c
	-@rm -f -v *pdfsync *synctex.gz *.fls

reset:
	latexmk -CA
	-@rm -f -v *pdfsync *synctex.gz *.fls
