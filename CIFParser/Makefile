
BISON_PATH=/usr/local/Cellar/bison/3.1/bin/bison
FLEX_PATH=/usr/local/Cellar/flex/2.6.4/bin/flex 

all: library

full: lexer parser

lexer:
	$(FLEX_PATH) -CFe --noyywrap --header-file=lex.yy.h -DLEXERMAIN=1 cif.l
	gcc lex.yy.c -ll -o ciflexer
#	/usr/local/Cellar/flex/2.6.4/bin/flex --header-file=lex.yy.h -DMAIN=1 xyz.l

parser:
	$(BISON_PATH) cif.y 
	$(FLEX_PATH) -CFe --noyywrap --header-file=lex.yy.h -DPARSERMAIN=1 --bison-bridge cif.l
	gcc -g3 -DPARSERMAIN=1 lex.yy.c cif.tab.c cif+callbacks.c -o cifparser

library:
	$(BISON_PATH) cif.y 
	$(FLEX_PATH) -CFe --noyywrap --header-file=lex.yy.h --bison-bridge cif.l

#install: full
#	/usr/local/Cellar/flex/2.6.4/bin/flex -CFe --header-file=lex.cif.h -P cif CIFLexer.l
#	gcc lex.cif.c CIFLexer_.m -fobjc-arc -DMAIN=1 -framework Cocoa -ll -o test

runcif:
	cat TestFiles/Test.cif | ./ciflexer

test:
#	cat TestFiles/3j3y.cif | ./test
#	cat TestFiles/Test.cif | ./ciflexer
#	./test.sh
#	@echo maybe ok
	@sh testscript.lex.sh

test1:
	cat TestFiles/Test.cif | ./ciflexer

test2:
#	./cifparser TestFiles/Test.cif
	@sh test.parse.sh

test3:
	cat TestFiles/Error.cif | ./cifparser
	cat TestFiles/TokenError1.cif | ./cifparser
	
clean:
	rm -f *.o *.hi *.cif.* *.yy.* *.tab.c *.tab.h test *~ ciflexer cifparse cifparser
	rm -rf cifparser.dSYM

.PHONY: all test clean

