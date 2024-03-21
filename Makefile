.DEFAULT_GOAL := compile

BISON = bison
FLEX = flex

CC = gcc
CFLAGS = -lfl

PREFIX = /usr/local
INSTALL = $(PREFIX)/bin
FILE = mips_assembler

install: compile
	install -m755 $(FILE) $(INSTALL)/$(FILE)

uninstall:
	rm -rf $(INSTALL)/$(FILE)

compile:
	${BISON} -yd ${FILE}.y
	${FLEX} ${FILE}.l
	${CC} ${CFLAGS} lex.yy.c y.tab.c label_list.c -o ${FILE}

clean:
	rm -rf y.tab.* lex.yy.c *.gch ${FILE}

.PHONY: compile clean
