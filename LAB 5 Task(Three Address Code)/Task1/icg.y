%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE *yyin;
int yylex();
void yyerror(const char *s);

char temp[100][10];
int tempCount = 0;

char* newTemp() {
    sprintf(temp[tempCount], "t%d", tempCount + 1);
    return temp[tempCount++];
}
%}

%union {
    char str[50];
}

%token <str> ID NUM
%token NL
%token AND OR NOT
%token POW IDIV
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN POW_ASSIGN IDIV_ASSIGN
%token GT LT

%type <str> Expression Term Factor Unary Primary Statement

%left OR
%left AND
%left GT LT
%left '+' '-'
%left '*' '/' '%' IDIV
%right POW
%right NOT

%%

Program
    : StatementList
    ;

StatementList
    : Statement
    | StatementList NL Statement
    ;

Statement
    : ID '=' Expression
      {
        printf("%s = %s\n", $1, $3);
      }
    | ID ADD_ASSIGN Expression
      {
        printf("%s = %s + %s\n", $1, $1, $3);
      }
    | ID SUB_ASSIGN Expression
      {
        printf("%s = %s - %s\n", $1, $1, $3);
      }
    | ID MUL_ASSIGN Expression
      {
        printf("%s = %s * %s\n", $1, $1, $3);
      }
    | ID DIV_ASSIGN Expression
      {
        printf("%s = %s / %s\n", $1, $1, $3);
      }
    | ID MOD_ASSIGN Expression
      {
        printf("%s = %s %% %s\n", $1, $1, $3);
      }
    | ID POW_ASSIGN Expression
      {
        printf("%s = %s ** %s\n", $1, $1, $3);
      }
    | ID IDIV_ASSIGN Expression
      {
        printf("%s = %s // %s\n", $1, $1, $3);
      }
    ;

Expression
    : Expression '+' Term
      {
        char *t = newTemp();
        printf("%s = %s + %s\n", t, $1, $3);
        strcpy($$, t);
      }
    | Expression '-' Term
      {
        char *t = newTemp();
        printf("%s = %s - %s\n", t, $1, $3);
        strcpy($$, t);
      }
    | Expression OR Term
      {
        char *t = newTemp();
        printf("%s = %s || %s\n", t, $1, $3);
        strcpy($$, t);
      }
    | Expression AND Term
      {
        char *t = newTemp();
        printf("%s = %s && %s\n", t, $1, $3);
        strcpy($$, t);
      }
    | Expression GT Term
      {
        char *t = newTemp();
        printf("%s = %s > %s\n", t, $1, $3);
        strcpy($$, t);
      }
    | Expression LT Term
      {
        char *t = newTemp();
        printf("%s = %s < %s\n", t, $1, $3);
        strcpy($$, t);
      }
    | Term
      {
        strcpy($$, $1);
      }
    ;

Term
    : Term '*' Factor
      {
        char *t = newTemp();
        printf("%s = %s * %s\n", t, $1, $3);
        strcpy($$, t);
      }
    | Term '/' Factor
      {
        char *t = newTemp();
        printf("%s = %s / %s\n", t, $1, $3);
        strcpy($$, t);
      }
    | Term IDIV Factor
      {
        char *t = newTemp();
        printf("%s = %s // %s\n", t, $1, $3);
        strcpy($$, t);
      }
    | Factor
      {
        strcpy($$, $1);
      }
    ;

Factor
    : Factor POW Unary
      {
        char *t = newTemp();
        printf("%s = %s ** %s\n", t, $1, $3);
        strcpy($$, t);
      }
    | Unary
      {
        strcpy($$, $1);
      }
    ;

Unary
    : NOT Unary
      {
        char *t = newTemp();
        printf("%s = ! %s\n", t, $2);
        strcpy($$, t);
      }
    | '-' Unary
      {
        char *t = newTemp();
        printf("%s = - %s\n", t, $2);
        strcpy($$, t);
      }
    | Primary
      {
        strcpy($$, $1);
      }
    ;

Primary
    : ID
      {
        strcpy($$, $1);
      }
    | NUM
      {
        strcpy($$, $1);
      }
    | '(' Expression ')'
      {
        strcpy($$, $2);
      }
    ;

%%

int main() {
    yyin = fopen("input.txt", "r");
    if (!yyin) {
        printf("Error opening input.txt\n");
        return 1;
    }
    yyparse();
    return 0;
}

void yyerror(const char *s) {
    printf("Error: %s\n", s);
}
