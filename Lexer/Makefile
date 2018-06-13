
all:
	/usr/local/Cellar/flex/2.6.4/bin/flex -CFe --header-file=lex.cif.h -P cif CIFLexer.l
	gcc lex.cif.c CIFLexer_.m -fobjc-arc -DMAIN=1 -framework Cocoa -ll -o test

install:
	/usr/local/Cellar/flex/2.6.4/bin/flex -CFe --header-file=lex.cif.h -P cif CIFLexer.l
	gcc lex.cif.c CIFLexer_.m -fobjc-arc -DMAIN=1 -framework Cocoa -ll -o test

test:
	./test.sh
	@echo maybe ok

clean:
	rm -f *.o *.hi *.cif.* *.tab.c *.tab.h test *~

.PHONY: all test clean

