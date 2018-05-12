/* File: symtab.c
 * A hash-table-based symbol table.
 * It uses separate chaining with linked lists to resolve hash collisions.
 * Deyuan Guo. Oct 13, 2013
 */

#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "symtab.h"

/* Number of hash entries */
#define HSIZE 211
/* A scope level to handle nested scopes */
static int level = 0;
/* A hash table using separate chaining with linked lists */
static node *table[HSIZE] = {0};

/* Get hash value of a symbol */
static unsigned int hvalue(char *s)
{
  unsigned int i = 0;
  while (*s) { i = (i << 2) + *s++; }
  return i % HSIZE;
}

/* Create a new node for a symbol */
static node* newnode(char *s)
{
  node *n;
  n = (node *)malloc(sizeof(*n));
  assert(n != NULL);
  n->next = NULL;
  n->symbol = (char *)malloc(strlen(s) + 1);
  assert(n->symbol != NULL);
  strcpy(n->symbol, s);
  n->level = level;
  return n;
}

/* Insert a symbol to the symbol table */
node* insert(char *s)
{
  node *n;
  unsigned int i;
  n = newnode(s);
  i = hvalue(s);
  n->next = table[i];
  table[i] = n;
  return n;
}

/* Lookup a symbol from the symbol table */
node* lookup(char *s)
{
  node *n;
  n = table[hvalue(s)];
  while (n != NULL) {
    if (strcmp(s, n->symbol) == 0) {
      return n;
    } else {
      n = n->next;
    }
  }
  return n;
}

/* Delete a symbol from the symbol table */
node* delete(char *s)
{
  node **p;
  p = table + hvalue(s);
  while (*p != NULL) {
    if (strcmp(s, (*p)->symbol) == 0) {
      node *n;
      n = *p;
      *p = (*p)->next;
      return n;
    } else {
      p = &((*p)->next);
    }
  }
  return NULL;
}

/* Open a nested scope */
void scope_open(void)
{
  level++;
}

/* Close a nested scope and remove local variables */
void scope_close(void)
{
  int i;
  level--;
  for (i = 0; i < HSIZE; i++) {
    while (table[i] != NULL && table[i]->level > level) {
      node *n = table[i];
      table[i] = n->next;
      free(n);
    }
  }
}

