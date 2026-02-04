%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE *yyin;
int yylex();
void yyerror(const char *s);

FILE *tac;
FILE *tc;

char temp[100][10];
int tempCount = 0;

char* newTemp() {
    sprintf(temp[tempCount], "t%d", tempCount + 1);
    return temp[tempCount++];
}

char regStack[100][10];
int top = -1;

void push(char* reg) {
    top++;
    strcpy(regStack[top], reg);
}

char* pop() {
    if (top >= 0) {
        return regStack[top--];
    }
    return "R0";
}

int regCount = 0;
char* getNextReg() {
    static char reg[10];
    sprintf(reg, "R%d", regCount++);
    return reg;
}

void resetRegs() {
    regCount = 0;
    top = -1;
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
        fprintf(tac, "%s = %s \n", $1, $3);
        
        char* reg = pop();
        fprintf(tc, "MOV %s, %s \n", $1, reg);
        fprintf(tc, " \n");
        
        resetRegs();
      }
    | ID ADD_ASSIGN Expression
      {
        char* t = newTemp();
        fprintf(tac, "%s = %s + %s \n", t, $1, $3);
        fprintf(tac, "%s = %s \n", $1, t);
        
        char* rop = pop();
        char* lreg = getNextReg();
        fprintf(tc, "MOV %s , %s \n", lreg, $1);
        fprintf(tc, "ADD %s , %s \n", lreg, rop);
        fprintf(tc, "MOV %s, %s \n", $1, lreg);
        fprintf(tc, " \n");
        
        resetRegs();
      }
    | ID SUB_ASSIGN Expression
      {
        char* t = newTemp();
        fprintf(tac, "%s = %s - %s \n", t, $1, $3);
        fprintf(tac, "%s = %s \n", $1, t);
        
        char* rop = pop();
        char* lreg = getNextReg();
        fprintf(tc, "MOV %s , %s \n", lreg, $1);
        fprintf(tc, "SUB %s , %s \n", lreg, rop);
        fprintf(tc, "MOV %s, %s \n", $1, lreg);
        fprintf(tc, " \n");
        
        resetRegs();
      }
    | ID MUL_ASSIGN Expression
      {
        char* t = newTemp();
        fprintf(tac, "%s = %s * %s \n", t, $1, $3);
        fprintf(tac, "%s = %s \n", $1, t);
        
        char* rop = pop();
        char* lreg = getNextReg();
        fprintf(tc, "MOV %s , %s \n", lreg, $1);
        fprintf(tc, "MUL %s , %s \n", lreg, rop);
        fprintf(tc, "MOV %s, %s \n", $1, lreg);
        fprintf(tc, " \n");
        
        resetRegs();
      }
    | ID DIV_ASSIGN Expression
      {
        char* t = newTemp();
        fprintf(tac, "%s = %s / %s \n", t, $1, $3);
        fprintf(tac, "%s = %s \n", $1, t);
        
        char* rop = pop();
        char* lreg = getNextReg();
        fprintf(tc, "MOV %s , %s \n", lreg, $1);
        fprintf(tc, "DIV %s , %s \n", lreg, rop);
        fprintf(tc, "MOV %s, %s \n", $1, lreg);
        fprintf(tc, " \n");
        
        resetRegs();
      }
    | ID MOD_ASSIGN Expression
      {
        char* t = newTemp();
        fprintf(tac, "%s = %s %% %s \n", t, $1, $3);
        fprintf(tac, "%s = %s \n", $1, t);
        
        char* rop = pop();
        char* lreg = getNextReg();
        fprintf(tc, "MOV %s , %s \n", lreg, $1);
        fprintf(tc, "MOD %s , %s \n", lreg, rop);
        fprintf(tc, "MOV %s, %s \n", $1, lreg);
        fprintf(tc, " \n");
        
        resetRegs();
      }
    | ID POW_ASSIGN Expression
      {
        char* t = newTemp();
        fprintf(tac, "%s = %s ** %s \n", t, $1, $3);
        fprintf(tac, "%s = %s \n", $1, t);
        
        char* rop = pop();
        char* lreg = getNextReg();
        fprintf(tc, "MOV %s , %s \n", lreg, $1);
        fprintf(tc, "POW %s , %s \n", lreg, rop);
        fprintf(tc, "MOV %s, %s \n", $1, lreg);
        fprintf(tc, " \n");
        
        resetRegs();
      }
    | ID IDIV_ASSIGN Expression
      {
        char* t = newTemp();
        fprintf(tac, "%s = %s // %s \n", t, $1, $3);
        fprintf(tac, "%s = %s \n", $1, t);
        
        char* rop = pop();
        char* lreg = getNextReg();
        fprintf(tc, "MOV %s , %s \n", lreg, $1);
        fprintf(tc, "IDIV %s , %s \n", lreg, rop);
        fprintf(tc, "MOV %s, %s \n", $1, lreg);
        fprintf(tc, " \n");
        
        resetRegs();
      }
    ;

Expression
    : Expression '+' Term
      {
        char *t = newTemp();
        fprintf(tac, "%s = %s + %s \n", t, $1, $3);
        strcpy($$, t);
        
        char* rop = pop();
        char* lop = pop();
        
        if (lop[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s \n", reg, lop);
            lop = reg;
        }
        
        fprintf(tc, "ADD %s , %s \n", lop, rop);
        push(lop);
      }
    | Expression '-' Term
      {
        char *t = newTemp();
        fprintf(tac, "%s = %s - %s \n", t, $1, $3);
        strcpy($$, t);
        
        char* rop = pop();
        char* lop = pop();
        
        if (lop[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s \n", reg, lop);
            lop = reg;
        }
        
        fprintf(tc, "SUB %s , %s \n", lop, rop);
        push(lop);
      }
    | Expression OR Term
      {
        char *t = newTemp();
        fprintf(tac, "%s = %s || %s \n", t, $1, $3);
        strcpy($$, t);
        
        char* rop = pop();
        char* lop = pop();
        fprintf(tc, "OR %s , %s \n", lop, rop);
        push(lop);
      }
    | Expression AND Term
      {
        char *t = newTemp();
        fprintf(tac, "%s = %s && %s \n", t, $1, $3);
        strcpy($$, t);
        
        char* rop = pop();
        char* lop = pop();
        fprintf(tc, "AND %s , %s \n", lop, rop);
        push(lop);
      }
    | Expression GT Term
      {
        char *t = newTemp();
        fprintf(tac, "%s = %s > %s \n", t, $1, $3);
        strcpy($$, t);
        
        char* rop = pop();
        char* lop = pop();
        fprintf(tc, "CMPGT %s , %s \n", lop, rop);
        fprintf(tc, " \n");
        push(lop);
      }
    | Expression LT Term
      {
        char *t = newTemp();
        fprintf(tac, "%s = %s < %s \n", t, $1, $3);
        strcpy($$, t);
        
        char* rop = pop();
        char* lop = pop();
        fprintf(tc, "CMPLT %s , %s \n", lop, rop);
        fprintf(tc, " \n");
        push(lop);
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
        fprintf(tac, "%s = %s * %s \n", t, $1, $3);
        strcpy($$, t);
        
        char* rop = pop();
        char* lop = pop();
        
        if (lop[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s \n", reg, lop);
            lop = reg;
        }
        
        fprintf(tc, "MUL %s , %s \n", lop, rop);
        push(lop);
      }
    | Term '/' Factor
      {
        char *t = newTemp();
        fprintf(tac, "%s = %s / %s \n", t, $1, $3);
        strcpy($$, t);
        
        char* rop = pop();
        char* lop = pop();
        
        if (lop[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s \n", reg, lop);
            lop = reg;
        }
        
        fprintf(tc, "DIV %s , %s \n", lop, rop);
        push(lop);
      }
    | Term '%' Factor
      {
        char *t = newTemp();
        fprintf(tac, "%s = %s %% %s \n", t, $1, $3);
        strcpy($$, t);
        
        char* rop = pop();
        char* lop = pop();
        
        if (lop[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s \n", reg, lop);
            lop = reg;
        }
        
        fprintf(tc, "MOD %s , %s \n", lop, rop);
        push(lop);
      }
    | Term IDIV Factor
      {
        char *t = newTemp();
        fprintf(tac, "%s = %s // %s \n", t, $1, $3);
        strcpy($$, t);
        
        char* rop = pop();
        char* lop = pop();
        
        if (lop[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s \n", reg, lop);
            lop = reg;
        }
        
        fprintf(tc, "IDIV %s , %s \n", lop, rop);
        push(lop);
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
        fprintf(tac, "%s = %s ** %s \n", t, $1, $3);
        strcpy($$, t);
        
        char* rop = pop();
        char* lop = pop();
        
        if (lop[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s \n", reg, lop);
            lop = reg;
        }
        
        fprintf(tc, "POW %s , %s \n", lop, rop);
        push(lop);
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
        fprintf(tac, "%s = !%s \n", t, $2);
        strcpy($$, t);
        
        char* op = pop();
        
        if (op[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s \n", reg, op);
            op = reg;
        }
        
        fprintf(tc, "NOT %s \n", op);
        push(op);
      }
    | '-' Unary
      {
        char *t = newTemp();
        fprintf(tac, "%s = -%s \n", t, $2);
        strcpy($$, t);
        
        char* op = pop();
        
        if (op[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s \n", reg, op);
            op = reg;
        }
        
        fprintf(tc, "NEG %s \n", op);
        push(op);
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
        char* reg = getNextReg();
        fprintf(tc, "MOV %s , %s \n", reg, $1);
        push(reg);
      }
    | NUM
      {
        strcpy($$, $1);
        char imm[20];
        sprintf(imm, "#%s", $1);
        push(imm);
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
    
    tac = fopen("tac.txt", "w");
    tc = fopen("tc.txt", "w");
    
    yyparse();
    
    fclose(tac);
    fclose(tc);
    fclose(yyin);
    
    return 0;
}

void yyerror(const char *s) {
    printf("Error: %s\n", s);
}