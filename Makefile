# basic makefile for D language - made by darkstalker slightly modified by matovitch
DCC = dmd
DFLAGS = -w
LIBS =
SRC = $(wildcard *.d)
OBJ = $(SRC:.d=.o)
INT = $(SRC:.d=.di)
DOC = $(SRC:.d=.html)
OUT = $(shell basename `pwd`)

.PHONY: all debug release profile clean doc
all: debug
debug: DFLAGS += -g -debug
release: DFLAGS += -O -release -inline -noboundscheck
profile: DFLAGS += -g -O -profile
debug release profile: $(OUT)
$(OUT): $(INT) $(OBJ)
	$(DCC) $(DFLAGS) -of$@ $(OBJ) $(LIBS)
 
%.o: %.d %.di
	$(DCC) $(DFLAGS) -c $<

$(INT):
	$(DCC) $(DFLAGS) -c -o- -H $(SRC)
 
doc:
	$(DCC) $(DFLAGS) -c -o- -D $(SRC)
 
clean:
	rm -f *~ $(DOC) $(INT) $(OBJ) $(OUT) trace.{def,log}