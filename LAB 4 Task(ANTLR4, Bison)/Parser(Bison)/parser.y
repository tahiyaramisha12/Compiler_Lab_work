%{
#include <stdio.h>
#include <stdlib.h>

extern FILE *yyin; 

void yyerror(const char *s);
int yylex();
%}

%token IF ELSE
%token ID NUMBER
%token ASSIGN SEMI
%token PLUS DIV LT
%token LPAREN RPAREN LBRACE RBRACE

%%

program
    : stmt_list
      {
        printf("Parsing successful!\n");
      }
    ;

stmt_list
    : stmt_list stmt
    | stmt
    ;

stmt
    : assign_stmt
    | if_stmt
    ;

assign_stmt
    : ID ASSIGN expr SEMI
    ;

if_stmt
    : IF LPAREN condition RPAREN LBRACE stmt_list RBRACE
    | IF LPAREN condition RPAREN LBRACE stmt_list RBRACE
      ELSE LBRACE stmt_list RBRACE
    ;

condition
    : ID
    | ID LT ID
    ;

expr
    : expr PLUS term
    | term
    ;

term
    : term DIV factor
    | factor
    ;

factor
    : ID
    | NUMBER
    ;

%%

void yyerror(const char *s) {
    printf("Syntax Error!\n");
}

int main() {
    FILE *fp = fopen("input.txt", "r");
    if (!fp) {
        printf("Cannot open input file\n");
        return 1;
    }

    yyin = fp;
    yyparse();
    fclose(fp);
    return 0;
}
