/* File: symtab.h
 * A hash-table-based symbol table.
 * It uses separate chaining with linked lists to resolve hash collisions.
 * Deyuan Guo. Oct 13, 2013
 */

#ifndef SYMTAB_H
#define SYMTAB_H

/* Data structure for a symbol in the symbol table, used by scanner and parser */
typedef struct node {
  struct node *next;  /* for separate chaining */
  char *symbol;       /* symbol name */
  int level;          /* scope level */
} node;

extern node* insert(char *s);
extern node* lookup(char *s);
extern node* delete(char *s);
extern void scope_open(void);
extern void scope_close(void);

#endif

