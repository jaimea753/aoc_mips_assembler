%{
#include <string.h>
#include "y.tab.h"

int line_counter = 0;

char *parse_label(char *label) {
    int len = strlen(label);
    label[len-1] = '\0';
    return label;
}

%}

%%
"."[Dd][Aa][Tt][Aa] {return(DATA_LABEL);}
"."[Cc][Oo][Dd][Ee] {return(TEXT_LABEL);}

[Rr][0-9]+ {yylval.num = atoi(&yytext[1]); return(REG);}
"-"?[0-9]+ {yylval.im = atoi(yytext); return(IM);}
"0x"[0-9A-Fa-f]+ {yylval.im = strtol(&yytext[2], NULL, 16); return(IM);}
"@"[0-9]+ {yylval.num = atoi(&yytext[1]); return(D_ADDR);}

[Nn][Oo][Pp] {return(NOP);}
[Aa][Dd][Dd] {return(ADD);}
[Ss][Uu][Bb] {return(SUB);}
[Aa][Nn][Dd] {return(AND);}
[Oo][Rr] {return(OR);}
[Ll][Ww] {return(LW);}
[Ss][Ww] {return(SW);}
[Bb][Ee][Qq] {return(BEQ);}
[Jj][Aa][Ll] {return(JAL);}
[Rr][Ee][Tt] {return(RET);}
[Rr][Tt][Ee] {return(RTE);}
[Uu][Nn][Dd][Ee][Ff] {return(UNDEF);}

"(" {return (OP);}
")" {return (CP);}
"," {return (COMMA);}

^[ ]*[A-Za-z0-9_]+":" {yylval.nombre = parse_label(yytext); return(LABEL);}
[A-Za-z0-9_]+ {yylval.nombre = yytext; return(LABEL);}

^[ \t]*(;.*)?"\n" {line_counter++;} // Líneas en blanco
;.* {} // Comentarios
"\n" {line_counter++; return(EOL);}
" " {}
"\t" {}
. {fprintf(stderr, "%sError de reconocimiento en la línea: %d\n", yytext, line_counter + 1);}
%%

