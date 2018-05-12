/* File: turtle.y
 * Syntax parser for the turtle language
 * Deyuan Guo. Oct 13, 2013
 */

%{
#include <stdio.h>
#include "symtab.h"
%}

%error-verbose

/* %union defines what can be returned from scanner to parser */
/* This will be used to define YYSTYPE, yylval, and type of tokens */
/* i: integer. n: symbol table node. d: double */
%union { int i; node *n; double d; }

/* Tokens */
%token GO TURN VAR JUMP
%token FOR STEP TO DO
%token COPEN CCLOSE
%token SIN COS SQRT
%token <d> FLOAT
%token <n> ID
%token <i> NUMBER
%token SEMICOLON PLUS MINUS TIMES DIV OPEN CLOSE ASSIGN
%token IF THEN ELSE WHILE PROCEDURE CALL PARAM
%token LT LE GT GE EQ NE COMMA
%token UP DOWN NORTH SOUTH EAST WEST

%type <n> decl

/* Dangling Else Problem:
 * Optional else in nested if statements can be ambiguous, e.g. if-if-else,
 * because the else can be associate to either if.
 * We can use %prec, e.g. %nonassoc, to define precedence to resolve ambiguity:
 *   %nonassoc NOELSE
 *   %nonassoc ELSE
 * Or we can implement a LR parser.
 */

/* Syntax Parser: Define syntax rules of turtle language, translate to PostScript
 * LR Parsing: Left-to-right scanning, Rightmost derivation
 */
%%

/* Turtle program structure: head + declaration list + statement list + tail */
program: head decllist stmtlist tail;

head: { printf("%%!PS-Adobe\n"
               "%% This PostScript program is generate by the turtle program.\n"
               "%% Author: Deyuan Guo <guodeyuan@gmail.com>\n\n"
               "%% Usage: ./turtle < prog.tlt > prog.ps\n"
               "%% Save as *.ps and use a PostScript Viewer to open it.\n"
               "%% Note that there's no semantic analyzer, so be careful.\n\n"
               "/sinphi 0.0 def\n"
               "/cosphi 1.0 def\n"
               "/state true def\n"
               "/pi 4 1 1 atan mul def\n"
               "newpath 0 0 moveto\n\n"); };

tail:                                   { printf("\n1 setlinewidth\nstroke\nshowpage\n"); };

/* Rules for declaration list */
decllist:                               ;
decllist:     decllist decl             ;
decl:         VAR ID SEMICOLON          { printf("/turtle%s 0 def\n", $2->symbol); };

/* Rules for statements, use open/close to support nested statements and resolve dangling else problem */
stmtlist:                               ;
stmtlist:     stmtlist uplevelstmt      ;

uplevelstmt:  open_stmt | closed_stmt;

open_stmt:    open_for | open_while | open_if;
closed_stmt:  stmt | closed_for | closed_while | closed_if;

open_for:     forstmt open_stmt         { printf("} for\n"); };
closed_for:   forstmt closed_stmt       { printf("} for\n"); };
forstmt:      FOR ID ASSIGN expr STEP expr TO expr DO
                                        { printf("{ /turtle%s exch store\n", $2->symbol); };

open_while:   whilestmt open_stmt       { printf("} loop\n"); };
closed_while: whilestmt closed_stmt     { printf("} loop\n"); };
whilestmt:    WHILE                     { printf("{ "); }
              OPEN cmpexpr CLOSE        { printf("\n{} {exit} ifelse\n"); };

open_if:      ifcond uplevelstmt        { printf("} if\n"); };
open_if:      ifelsestmt open_stmt      { printf("} ifelse\n"); };
closed_if:    ifelsestmt closed_stmt    { printf("} ifelse\n"); };
ifelsestmt:   ifcond closed_stmt        { printf("} {\n"); }
              ELSE                      ;
ifcond:       IF OPEN cmpexpr CLOSE     { printf("{\n"); };
ifcond:       IF OPEN cmpexpr CLOSE THEN
                                        { printf("{\n"); };

stmt:         ID ASSIGN expr SEMICOLON  { printf("/turtle%s exch store\n", $1->symbol); };
stmt:         GO expr SEMICOLON         { printf("dup cosphi mul exch sinphi mul state {rlineto} {rmoveto} ifelse\n"); };
stmt:         JUMP expr SEMICOLON       { printf("dup cosphi mul exch sinphi mul rmoveto\n"); };
stmt:         TURN expr SEMICOLON       { printf("180 div pi mul sinphi cosphi atan add dup sin /sinphi exch store"
                                                 " cos /cosphi exch store\n"); };
stmt:         PROCEDURE ID              { printf("/turtleproc%s {\n20 dict begin\n", $2->symbol); }
              OPEN paramlist CLOSE
              COPEN stmtlist CCLOSE     { printf("end } bind def\n\n"); };
stmt:         ID OPEN arglist CLOSE SEMICOLON
                                        { printf("turtleproc%s\n", $1->symbol); };
stmt:         UP SEMICOLON              { printf("/state false store\n"); };
stmt:         DOWN SEMICOLON            { printf("/state true store\n"); };
stmt:         NORTH SEMICOLON           { printf("/sinphi 1.0 store /cosphi 0.0 store\n"); };
stmt:         SOUTH SEMICOLON           { printf("/sinphi -1.0 store /cosphi 0.0 store\n"); };
stmt:         EAST SEMICOLON            { printf("/sinphi 0.0 store /cosphi 1.0 store\n"); };
stmt:         WEST SEMICOLON            { printf("/sinphi 0.0 store /cosphi -1.0 store\n"); };
stmt:         COPEN stmtlist CCLOSE     ;

/* Rules for procedure parameter list, used by callee in procedure definition */
paramlist:                              ;
paramlist:    ID                        { printf("/turtle%s exch def\n", $1->symbol); };
paramlist:    ID COMMA paramlist        { printf("/turtle%s exch def\n", $1->symbol); };

/* Rules for procedure argument list, used by caller */
arglist:                                ;
arglist:      expr                      ;
arglist:      arglist COMMA expr        ;

/* Rules for comparison expressions, only used as conditions in if and while statements */
cmpexpr:      expr LT expr              { printf("lt "); };
cmpexpr:      expr LE expr              { printf("le "); };
cmpexpr:      expr GT expr              { printf("gt "); };
cmpexpr:      expr GE expr              { printf("ge "); };
cmpexpr:      expr EQ expr              { printf("eq "); };
cmpexpr:      expr NE expr              { printf("ne "); };
cmpexpr:      expr                      { printf("0 ne "); };

/* Rules for arithmetic expressions with precedence and rightmost derivation. */
/* Addition and subtraction. */
expr:         expr PLUS term            { printf("add "); };
expr:         expr MINUS term           { printf("sub "); };
expr:         term                      ;

/* Multiplication and division */
term:         term TIMES factor         { printf("mul "); };
term:         term DIV factor           { printf("div "); };
term:         factor                    ;

/* Unary operations */
factor:       MINUS atomic              { printf("neg "); };
factor:       PLUS atomic               ;
factor:       SIN factor                { printf("sin "); };
factor:       COS factor                { printf("cos "); };
factor:       SQRT factor               { printf("sqrt "); };
factor:       atomic                    ;

/* Atomic units, treat an expression with parentheses as an atomic unit */
atomic:       OPEN expr CLOSE           ;
atomic:       NUMBER                    { printf("%d ", $1); };
atomic:       FLOAT                     { printf("%f ", $1); };
atomic:       ID                        { printf("turtle%s ", $1->symbol); };
atomic:       PARAM                     ;

%%

/* Error processing */
int yyerror(char *msg)
{
  fprintf(stderr, "Error: %s\n", msg);
  return 0;
}

/* Main function of the syntax parser */
int main(void)
{
  yyparse();
  return 0;
}

