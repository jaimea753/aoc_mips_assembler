BISON = bison
FLEX = flex
CC = gcc

CFLAGS =
LDFLAGS = -lfl

PREFIX = /usr/local
INSTALL = $(PREFIX)/bin
FILE = mips_assembler

$(FILE): lex.yy.c y.tab.c
	${CC} ${CFLAGS} lex.yy.c y.tab.c label_list.c -o ${FILE} ${LDFLAGS}

install: 
	install -m755 $(FILE) $(INSTALL)/$(FILE)

uninstall:
	rm -rf $(INSTALL)/$(FILE)

lex.yy.c: mips_assembler.l
	${FLEX} ${FILE}.l

y.tab.c: mips_assembler.y
	${BISON} -yd ${FILE}.y

clean:
	rm -rf y.tab.* lex.yy.c *.gch ${FILE}

.PHONY: compile clean
