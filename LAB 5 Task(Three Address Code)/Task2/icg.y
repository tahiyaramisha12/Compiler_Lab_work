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
%token SQRT POW LOG EXP SIN COS TAN ABS

%type <str> Expression Term Factor FunctionCall

%left '+' '-'
%left '*' '/' '%'
%right UMINUS

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
    | Term '%' Factor
      {
        char *t = newTemp();
        printf("%s = %s %% %s\n", t, $1, $3);
        strcpy($$, t);
      }
    | Factor
      {
        strcpy($$, $1);
      }
    ;

Factor
    : '-' Factor %prec UMINUS
      {
        char *t = newTemp();
        printf("%s = -%s\n", t, $2);
        strcpy($$, t);
      }
    | '(' Expression ')'
      {
        strcpy($$, $2);
      }
    | FunctionCall
      {
        strcpy($$, $1);
      }
    | ID
      {
        strcpy($$, $1);
      }
    | NUM
      {
        strcpy($$, $1);
      }
    ;

FunctionCall
    : SQRT '(' Expression ')'
      {
        char *t = newTemp();
        printf("%s = sqrt ( %s )\n", t, $3);
        strcpy($$, t);
      }
    | LOG '(' Expression ')'
      {
        char *t = newTemp();
        printf("%s = log ( %s )\n", t, $3);
        strcpy($$, t);
      }
    | EXP '(' Expression ')'
      {
        char *t = newTemp();
        printf("%s = exp ( %s )\n", t, $3);
        strcpy($$, t);
      }
    | SIN '(' Expression ')'
      {
        char *t = newTemp();
        printf("%s = sin ( %s )\n", t, $3);
        strcpy($$, t);
      }
    | COS '(' Expression ')'
      {
        char *t = newTemp();
        printf("%s = cos ( %s )\n", t, $3);
        strcpy($$, t);
      }
    | TAN '(' Expression ')'
      {
        char *t = newTemp();
        printf("%s = tan ( %s )\n", t, $3);
        strcpy($$, t);
      }
    | ABS '(' Expression ')'
      {
        char *t = newTemp();
        printf("%s = abs ( %s )\n", t, $3);
        strcpy($$, t);
      }
    | POW '(' Expression ',' Expression ')'
      {
        char *t = newTemp();
        printf("%s = pow (%s , %s)\n", t, $3, $5);
        strcpy($$, t);
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
