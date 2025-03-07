#include "label_list.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void free_label_list(struct LABEL_LIST *list)
{
    struct LABEL_LIST_NODE *node = list->init;
    struct LABEL_LIST_NODE *aux = NULL;
    while (node)
    {
        aux = node->next;
        free(node);
        node = aux;
    }
}

int add_to_list(struct LABEL_LIST *list, char *label, unsigned int num_ins, int allow_duplicates)
{
    struct LABEL_LIST_NODE *node, *aux;
    if (!(list->init))
    {
        if (!(list->init = malloc(sizeof *(list->init))))
        {
            fprintf(stderr, "Error in list creation\n");
            exit(1);
        }
        node = list->init;
    }
    else
    {
        if (!allow_duplicates)
        {
            node = list->init;
            while (node)
            {
                if (!strcasecmp(node->label, label))
                    return 1;
                node = node->next;
            }
        }
        aux = list->current;
        if (!(aux->next = malloc(sizeof *(aux->next))))
        {
            fprintf(stderr, "Error adding element\n");
            exit(1);
        }
        node = aux->next;
    }

    node->label = strdup(label);
    node->num_ins = num_ins;

    list->current = node;
    return 0;
}

void debug_print_label_list(struct LABEL_LIST *list)
{
    struct LABEL_LIST_NODE *current = list->init;
    while (current)
    {
        printf("%s %d\n", current->label, (int)current->num_ins);
        current = current->next;
    }
}
