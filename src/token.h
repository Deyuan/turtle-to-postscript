/* File: token.h
 * Tokens in the turtle language
 * This file is used for developing the lexical scanner (turtle.l) only. Once
 * the syntax parser (turtle.y) is available, we can generate a turtle.tab.h
 * and use it to replace this file in turtle.l.
 * Deyuan Guo. Oct 13, 2013
 */

#ifndef TOKEN_H
#define TOKEN_H

#include "symtab.h"

#define GO        258
#define TURN      259
#define VAR       260
#define JUMP      261
#define FOR       262
#define STEP      263
#define TO        264
#define DO        265
#define COPEN     266
#define CCLOSE    267
#define SIN       268
#define COS       269
#define SQRT      270
#define FLOAT     271
#define ID        272
#define NUMBER    273
#define SEMICOLON 274
#define PLUS      275
#define MINUS     276
#define TIMES     277
#define DIV       278
#define OPEN      279
#define CLOSE     280
#define ASSIGN    281
#define IF        282
#define THEN      283
#define ELSE      284
#define WHILE     285
#define PROCEDURE 286
#define CALL      287
#define PARAM     288
#define LT        289
#define LE        290
#define GT        291
#define GE        292
#define EQ        293
#define NE        294
#define COMMA     295
#define UP        296
#define DOWN      297
#define NORTH     298
#define SOUTH     299
#define EAST      300
#define WEST      301

/* YYSTYPE is the type of token value */
typedef union YYSTYPE {
  int i;
  node *n;
  double d;
} YYSTYPE;

/* yylval holds the value of a token */
YYSTYPE yylval;

#endif

