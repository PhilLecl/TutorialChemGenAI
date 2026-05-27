.PHONY: all
all: main.pdf

.PHONY: watch
watch: main.typ
	typst watch main.typ

main.pdf: main.typ
	typst compile main.typ
