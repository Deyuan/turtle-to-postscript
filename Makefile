# Makefile
# turtle-to-postscript
# A Logo-to-PostScript programming language translator
# Deyuan Guo. Oct 13, 2013

# Usage:
#   make
#   make clean

# Notes:
#   VAR  = val        -> Lazy Set
#   VAR := val        -> Immediate Set
#   VAR ?= val        -> Set If Absent
#   VAR += val        -> Append
#   .PHONY            -> Not file targets

SRC      := src
OBJ      := build
DEMO     := demos
DEMO_TLT := $(wildcard $(DEMO)/*.tlt)
DEMO_PS  := $(addprefix $(OBJ)/,$(notdir $(DEMO_TLT:.tlt=.ps)))

.PHONY: all clean

all: $(OBJ) turtle $(DEMO_PS)

##############################################################################
# Create build dir
##############################################################################

$(OBJ):
	mkdir -v -p $(OBJ)

##############################################################################
# Make turtle executable
##############################################################################

turtle: $(OBJ)/turtle
	ln -s $(OBJ)/turtle

# No need to use -lfl if we set %option noyywrap in turtle.l
$(OBJ)/turtle: $(OBJ)/turtle.tab.o $(OBJ)/lex.yy.o $(OBJ)/symtab.o
	gcc $(OBJ)/lex.yy.o $(OBJ)/turtle.tab.o $(OBJ)/symtab.o -o $(OBJ)/turtle

# Turn off warning for implicit function declaration of yylex and yyerror
$(OBJ)/turtle.tab.o: $(OBJ)/turtle.tab.c $(OBJ)/turtle.tab.h $(SRC)/symtab.h
	gcc -c $(OBJ)/turtle.tab.c -o $(OBJ)/turtle.tab.o -I$(SRC) -Wno-implicit-function-declaration

$(OBJ)/turtle.tab.c $(OBJ)/turtle.tab.h: $(SRC)/turtle.y
	bison -d $(SRC)/turtle.y -b $(OBJ)/turtle

$(OBJ)/lex.yy.o: $(OBJ)/lex.yy.c $(OBJ)/turtle.tab.h $(SRC)/symtab.h
	gcc -c $(OBJ)/lex.yy.c -o $(OBJ)/lex.yy.o -I$(SRC)

$(OBJ)/lex.yy.c: $(SRC)/turtle.l
	flex -o $(OBJ)/lex.yy.c $(SRC)/turtle.l

$(OBJ)/symtab.o: $(SRC)/symtab.c $(SRC)/symtab.h
	gcc -c $(SRC)/symtab.c -o $(OBJ)/symtab.o -I$(SRC)

##############################################################################
# Make demos
##############################################################################

demos: $(DEMO_PS)

$(OBJ)/%.ps: $(DEMO)/%.tlt turtle
	./turtle < $< > $@

##############################################################################
# Clean up
##############################################################################

clean:
	rm -rf build
	rm -rf turtle


