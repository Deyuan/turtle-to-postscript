/* File: turtle.l
 * Lexical scanner for the turtle language
 * Deyuan Guo. Oct 13, 2013
 */

/* Set noyywrap option to avoid linking with the flex library -lfl */
/* An alternative way is to define: int yywrap(void) { return 1; } */
%option noyywrap

%{
#include "symtab.h"
/* Before turtle.tab.h is available, use token.h to develop the lexical
 * scanner. token.h includes definitions of tokens, YYSTYPE and yylval.
 * The scanner can pass yylval and tokens to syntax parser. */
/* #include "token.h" */
#include "turtle.tab.h"
%}

/* Define lexical scanning rules.
 * Special handling:
 *   - Open and close scopes: Let symbol table know
 *   - Variables: Lookup symbol in current scope, insert if not defined
 *   - Literals: Let yylval hold the value
 *   - Comments and spaces: Ignore
 */
%%

\/\/.*          ;
[[:space:]]     ;

GO              return GO;
TURN            return TURN;
VAR             return VAR;
JUMP            return JUMP;
FOR             return FOR;
STEP            return STEP;
TO              return TO;
DO              return DO;
BEGIN|\{        { scope_open(); return COPEN; }
END|\}          { scope_close(); return CCLOSE; }

IF              return IF;
THEN            return THEN;
ELSE            return ELSE;
WHILE           return WHILE;
PROCEDURE       return PROCEDURE;
CALL            return CALL;
PARAM           return PARAM;

UP              return UP;
DOWN            return DOWN;
NORTH           return NORTH;
SOUTH           return SOUTH;
EAST            return EAST;
WEST            return WEST;

sin             return SIN;
cos             return COS;
sqrt            return SQRT;

;               return SEMICOLON;
\+              return PLUS;
-               return MINUS;
\*              return TIMES;
\/              return DIV;
\(              return OPEN;
\)              return CLOSE;
=               return ASSIGN;
,               return COMMA;
\<              return LT;
\<=             return LE;
\>              return GT;
\>=             return GE;
==              return EQ;
\!=             return NE;

[a-z]+          { yylval.n = lookup(yytext);
                  if (yylval.n == NULL) {
                    yylval.n = insert(yytext);
                  }
                  return ID;
                }

[0-9]+\.[0-9]+  { yylval.d = atof(yytext); return FLOAT; }
[0-9]+          { yylval.i = atoi(yytext); return NUMBER; }

[A-Za-z0-9]+    { fprintf(stderr, "Unexpected token \"%s\"\n", yytext); }
.               { fprintf(stderr, "Unexpected character %c (%2X)\n", yytext[0], yytext[0]); }

%%

