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
        fprintf(tac, "%s = %s\n", $1, $3);
        
        char* reg = pop();
        fprintf(tc, "MOV %s, %s\n", $1, reg);
        fprintf(tc, "\n");
        
        resetRegs();
      }
    ;

Expression
    : Expression '+' Term
      {
        char *t = newTemp();
        fprintf(tac, "%s = %s + %s\n", t, $1, $3);
        strcpy($$, t);
        
        char* rop = pop();
        char* lop = pop();
        
        if (lop[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s\n", reg, lop);
            lop = reg;
        }
        
        fprintf(tc, "ADD %s , %s\n", lop, rop);
        push(lop);
      }
    | Expression '-' Term
      {
        char *t = newTemp();
        fprintf(tac, "%s = %s - %s\n", t, $1, $3);
        strcpy($$, t);
        
        char* rop = pop();
        char* lop = pop();
        
        if (lop[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s\n", reg, lop);
            lop = reg;
        }
        
        fprintf(tc, "SUB %s , %s\n", lop, rop);
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
        fprintf(tac, "%s = %s * %s\n", t, $1, $3);
        strcpy($$, t);
        
        char* rop = pop();
        char* lop = pop();
        
        if (lop[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s\n", reg, lop);
            lop = reg;
        }
        
        fprintf(tc, "MUL %s , %s\n", lop, rop);
        push(lop);
      }
    | Term '/' Factor
      {
        char *t = newTemp();
        fprintf(tac, "%s = %s / %s\n", t, $1, $3);
        strcpy($$, t);
        
        char* rop = pop();
        char* lop = pop();
        
        if (lop[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s\n", reg, lop);
            lop = reg;
        }
        
        fprintf(tc, "DIV %s , %s\n", lop, rop);
        push(lop);
      }
    | Term '%' Factor
      {
        char *t = newTemp();
        fprintf(tac, "%s = %s %% %s\n", t, $1, $3);
        strcpy($$, t);
        
        char* rop = pop();
        char* lop = pop();
        
        if (lop[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s\n", reg, lop);
            lop = reg;
        }
        
        fprintf(tc, "MOD %s , %s\n", lop, rop);
        push(lop);
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
        fprintf(tac, "%s = -%s\n", t, $2);
        strcpy($$, t);
        
        char* op = pop();
        
        if (op[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s\n", reg, op);
            op = reg;
        }
        
        fprintf(tc, "NEG %s\n", op);
        push(op);
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
        char* reg = getNextReg();
        fprintf(tc, "MOV %s , %s\n", reg, $1);
        push(reg);
      }
    | NUM
      {
        strcpy($$, $1);
        char imm[20];
        sprintf(imm, "#%s", $1);
        push(imm);
      }
    ;

FunctionCall
    : SQRT '(' Expression ')'
      {
        char *t = newTemp();
        fprintf(tac, "%s = sqrt (%s)\n", t, $3);
        strcpy($$, t);
        
        char* op = pop();
        
        if (op[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s\n", reg, op);
            op = reg;
        }
        
        fprintf(tc, "SQRT %s\n", op);
        push(op);
      }
    | LOG '(' Expression ')'
      {
        char *t = newTemp();
        fprintf(tac, "%s = log (%s)\n", t, $3);
        strcpy($$, t);
        
        char* op = pop();
        
        if (op[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s\n", reg, op);
            op = reg;
        }
        
        fprintf(tc, "LOG %s\n", op);
        push(op);
      }
    | EXP '(' Expression ')'
      {
        char *t = newTemp();
        fprintf(tac, "%s = exp (%s)\n", t, $3);
        strcpy($$, t);
        
        char* op = pop();
        
        if (op[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s\n", reg, op);
            op = reg;
        }
        
        fprintf(tc, "EXP %s\n", op);
        push(op);
      }
    | SIN '(' Expression ')'
      {
        char *t = newTemp();
        fprintf(tac, "%s = sin (%s)\n", t, $3);
        strcpy($$, t);
        
        char* op = pop();
        
        if (op[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s\n", reg, op);
            op = reg;
        }
        
        fprintf(tc, "SIN %s\n", op);
        push(op);
      }
    | COS '(' Expression ')'
      {
        char *t = newTemp();
        fprintf(tac, "%s = cos (%s)\n", t, $3);
        strcpy($$, t);
        
        char* op = pop();
        
        if (op[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s\n", reg, op);
            op = reg;
        }
        
        fprintf(tc, "COS %s\n", op);
        push(op);
      }
    | TAN '(' Expression ')'
      {
        char *t = newTemp();
        fprintf(tac, "%s = tan (%s)\n", t, $3);
        strcpy($$, t);
        
        char* op = pop();
        
        if (op[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s\n", reg, op);
            op = reg;
        }
        
        fprintf(tc, "TAN %s\n", op);
        push(op);
      }
    | ABS '(' Expression ')'
      {
        char *t = newTemp();
        fprintf(tac, "%s = abs (%s )\n", t, $3);
        strcpy($$, t);
        
        char* op = pop();
        
        if (op[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s\n", reg, op);
            op = reg;
        }
        
        fprintf(tc, "ABS %s\n", op);
        push(op);
      }
    | POW '(' Expression ',' Expression ')'
      {
        char *t = newTemp();
        fprintf(tac, "%s = pow (%s, %s)\n", t, $3, $5);
        strcpy($$, t);
        
        char* rop = pop();
        char* lop = pop();
        
        if (lop[0] == '#') {
            char* reg = getNextReg();
            fprintf(tc, "MOV %s , %s\n", reg, lop);
            lop = reg;
        }
        
        fprintf(tc, "POW %s , %s\n", lop, rop);
        push(lop);
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