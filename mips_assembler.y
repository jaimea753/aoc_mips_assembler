%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

#include "MIPS.h"
#include "label_list.h"

#define INS_PER_LINE 8
#define LINES 16 
#define INSTRUCTION_SIZE LINES*INS_PER_LINE
#define DATA_SIZE LINES*INS_PER_LINE

uint32_t MEM_I[INSTRUCTION_SIZE] = {0};
uint32_t MEM_D[DATA_SIZE] = {0};

int contador_ins = 0;
struct LABEL_LIST list_labels, list_ins;

void 
add_MEM_I(uint32_t ins) 
{
    static int numIns = 0;
    MEM_I[numIns++] = ins;
}

void 
add_MEM_D(int pos, int data) 
{
    if (data < 0) data = (uint32_t)(0xFFFFFFFF + 1 + data);
    MEM_D[pos] = data;
}

uint32_t 
arit_ins(unsigned int aluop, unsigned int rd, unsigned int rs, unsigned int rt)
{
    return (ARIT_OPCODE << 26) + (rs << 21) + (rt << 16) + (rd << 11) + aluop;
}

uint32_t 
reg_reg_im_ins(unsigned int opcode, unsigned int rs, unsigned int rt, int im) 
{
    if (im < 0) im = 0xFFFF + 1 + im;
    return (opcode << 26) + (rs << 21) + (rt << 16) + im;
}

uint32_t 
reg_ins(unsigned int opcode, unsigned int rt, int im) 
{
    if (im < 0) 
        im = 0xFFFF + 1 + im;
    return (opcode << 26) + (rt << 16) + im;
}
%}

%union {
    char* nombre;
    unsigned int num;
    int im;
}

%token DATA_LABEL TEXT_LABEL
%token NOP LW SW BEQ JAL RET RTE
%token UNDEF
%token ADD SUB AND OR
%token REG IM LABEL
%token EOL OP CP COMMA
%token D_ADDR
%start file

//%type<nombre> ins
%type<num> REG ins D_ADDR
%type<im> IM 
%type<nombre> LABEL

%%
file : DATA_LABEL EOL data TEXT_LABEL EOL code

data : /* nada */
    | data D_ADDR IM EOL {add_MEM_D($2, $3);}

code : /* nada */ {}
    | code LABEL ins EOL {
                            if (add_to_list(&list_labels, $2, contador_ins, 1)) {  
                                fprintf(stderr, "Error: label %s aparece varias veces.\n", $2);
                                exit(1);
                            }
                            contador_ins++;
                            add_MEM_I($3); 
                         }
    | code ins EOL {add_MEM_I($2); contador_ins++;}
    ;

ins : NOP { $$ = NOP_OPCODE << 26; }
    | ADD REG COMMA REG COMMA REG {$$ = arit_ins(ADD_ALUOP, $2, $4, $6);}
    | SUB REG COMMA REG COMMA REG {$$ = arit_ins(SUB_ALUOP, $2, $4, $6);}
    | AND REG COMMA REG COMMA REG {$$ = arit_ins(AND_ALUOP, $2, $4, $6);}
    | OR REG COMMA REG COMMA REG {$$ = arit_ins(OR_ALUOP, $2, $4, $6);}
    | LW REG COMMA IM OP REG CP {$$ = reg_reg_im_ins(LW_OPCODE, $6, $2, $4);}
    | SW REG COMMA IM OP REG CP {$$ = reg_reg_im_ins(SW_OPCODE, $6, $2, $4);}
    | BEQ REG COMMA REG COMMA IM  {$$ = reg_reg_im_ins(BEQ_OPCODE, $2, $4, $6);}
    | BEQ REG COMMA REG COMMA LABEL  {
                                        $$ = reg_reg_im_ins(BEQ_OPCODE, $2, $4, 0);
                                        add_to_list(&list_ins, $6, contador_ins, 1);
                                       }
    | JAL REG COMMA IM {$$ = reg_ins(JAL_OPCODE, $2, $4);}
    | JAL REG COMMA LABEL {          
                                        $$ = reg_ins(JAL_OPCODE, $2, 0);
                                        add_to_list(&list_ins, $4, contador_ins, 1);
                             }
    | RET REG {$$ = ((RET_OPCODE << 26) + ($2 << 21));}
    | RTE {$$ = RTE_OPCODE << 26;}
    | UNDEF {$$ = 0xFFFFFFFF;}
    ;

%%

void 
write_MEM_I(void) 
{
    FILE *fd = fopen("RAM-I.txt", "w");
    int count = 0;
    fprintf(fd, "(");
    for (int i = 0; i < LINES; i++) 
    {
        for (int j = 0; j < INS_PER_LINE; j++) 
        {
            fprintf(fd, "X\"%08X\"", MEM_I[count++]);
            if (j == INS_PER_LINE - 1) 
            {
                if (i == LINES - 1) 
                    fprintf(fd, ");\n");
                else 
                    fprintf(fd, ",\n");
            }
            else fprintf(fd, ", ");
        }
    }
    fclose(fd);
}

void write_MEM_D(void)
{
    FILE *fd = fopen("RAM-D.txt", "w");
    int count = 0;
    fprintf(fd, "(");
    for (int i = 0; i < LINES; i++) 
    {
        for (int j = 0; j < INS_PER_LINE; j++) 
        {
            fprintf(fd, "X\"%08X\"", MEM_D[count++]);
            if (j == INS_PER_LINE - 1) 
            {
                if (i == LINES - 1) 
                    fprintf(fd, ");\n");
                else fprintf(fd, ",\n");
            }
            else fprintf(fd, ", ");
        }
    }
    fclose(fd);
}

int 
yyerror(char *s) 
{
    printf("\n%s\n", s);
    return 0;
}

void 
solve_labels() 
{
    struct LABEL_LIST_NODE *ptr1, *ptr2;
    ptr1 = list_ins.init;
    while (ptr1) {
        ptr2 = list_labels.init;
        while (ptr2) 
        {
            if (!strcasecmp(ptr1->label, ptr2->label)) 
            {
                int diff = ptr2->num_ins - ptr1->num_ins - 1;
                if (diff < 0) diff = 0xFFFF + 1 + diff;
                MEM_I[ptr1->num_ins] += diff;
            }
            ptr2 = ptr2->next;
        }
        ptr1 = ptr1->next;
    }
}

int 
main(int argc, char *argv[]) 
{
    if (argc == 2)
        stdin = fopen(argv[1], "r");
    else if (argc != 1)
        fprintf(stderr, "Error en los parámetros\n");
    yyparse();
    solve_labels();
    write_MEM_I();
    write_MEM_D();
    free_label_list(&list_labels);
    free_label_list(&list_ins);
}
