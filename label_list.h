#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct LABEL_LIST {
    struct LABEL_LIST_NODE *init, *current;
};

struct LABEL_LIST_NODE {
    char* label;
    unsigned long num_ins;
    struct LABEL_LIST_NODE *next;
};

void free_label_list(struct LABEL_LIST *list);

int add_to_list(struct LABEL_LIST *list, char *label, unsigned int num_ins, int allow_duplicates);

void debug_print_label_list(struct LABEL_LIST *list);

