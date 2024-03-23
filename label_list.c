#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "label_list.h"

void free_label_list(struct LABEL_LIST *list) {
    struct LABEL_LIST_NODE *node = list->init;
    struct LABEL_LIST_NODE *aux = NULL;
    while (node) {
        aux = node->next;
        free(node);
        node = aux;
    }
}

int add_to_list(struct LABEL_LIST *list, char *label, unsigned long num_ins, int allow_duplicates) {
    struct LABEL_LIST_NODE *node, *aux;
    if (!(list->init)) {
        list->init = (struct LABEL_LIST_NODE *)malloc(sizeof *(list->init));
        node = list->init;
    }
    else {
        if (!allow_duplicates) {
            node = list->init;
            while (node) {
                if (!strcasecmp(node->label, label)) return 1;
                node = node->next;
            }
        }
        aux = list->current;
        aux->next = (struct LABEL_LIST_NODE *)malloc(sizeof *(aux->next));
        node = aux->next;
    }

    node->label = strdup(label);
    node->num_ins = num_ins;

    list->current = node; 
    return 0;
}

void debug_print_label_list(struct LABEL_LIST *list) {
    struct LABEL_LIST_NODE *current = list->init;
    while (current) {
        printf("%s %d\n", current->label, current->num_ins);
        current = current->next;
    }
}

