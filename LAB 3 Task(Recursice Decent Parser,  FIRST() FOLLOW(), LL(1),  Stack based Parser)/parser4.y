%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();

#define MAX_STACK 100
char stack[MAX_STACK][10];
int top = -1;

char input_buffer[100];
int input_pos = 0;

void push(const char* symbol) {
    if (top < MAX_STACK - 1) {
        strcpy(stack[++top], symbol);
    }
}

char* pop() {
    if (top >= 0) {
        return stack[top--];
    }
    return NULL;
}

void print_stack() {
    int i;
    printf("$");
    for (i = 0; i <= top; i++) {
        printf("%s", stack[i]);
    }
}

void print_input() {
    printf("%s", &input_buffer[input_pos]);
}

void print_step(const char* action) {
    print_stack();
    printf("\t\t");
    print_input();
    printf("\t\t%s\n", action);
}

void parse_ll1(const char* str);

%}

%token IDENTIFIER PLUS DOLLAR EPSILON

%%

/* Grammar Rules - LL(1) Grammar */
E: T X
   ;

X: PLUS T X
   | EPSILON
   ;

T: IDENTIFIER
   ;

%%

void parse_ll1(const char* str) {
    strcpy(input_buffer, str);
    input_pos = 0;
    
    top = -1;
    push("E");
    
    printf("Stack\t\tInput\t\tAction\n");
    
    while (top >= 0) {
        char* stack_top = stack[top];
        char current_input = input_buffer[input_pos];
        
        if (strcmp(stack_top, "E") == 0) {
            pop();
            push("X");
            push("T");
            print_step("E -> TX");
        }
        else if (strcmp(stack_top, "T") == 0) {
            if (current_input == 'i') {
                pop();
                push("i");
                print_step("T -> i");
            } else {
                printf("Error: Expected 'i'\n");
                return;
            }
        }
        else if (strcmp(stack_top, "X") == 0) {
            if (current_input == '+') {
                pop();
                push("X");
                push("T");
                push("+");
                print_step("X -> +TX");
            } else if (current_input == '$') {
                pop();
                print_step("X -> @");
            } else {
                printf("Error: Unexpected symbol '%c'\n", current_input);
                return;
            }
        }
        else if (strcmp(stack_top, "i") == 0) {
            if (current_input == 'i') {
                pop();
                print_step("Match i");
                input_pos++;
            } else {
                printf("Error: Expected 'i' in input\n");
                return;
            }
        }
        else if (strcmp(stack_top, "+") == 0) {
            if (current_input == '+') {
                pop();
                print_step("Match +");
                input_pos++;
            } else {
                printf("Error: Expected '+' in input\n");
                return;
            }
        }
    }
    
    if (input_buffer[input_pos] == '$') {
        printf("$\t\t$\t\tMatch $\n");
        printf("\nString Accepted\n");
    } else {
        printf("\nError: Input not fully consumed\n");
    }
}

int main() {
    char input_str[100];
    int i, j;
    
    printf("Enter string to parse (end with $): ");
    if (fgets(input_str, sizeof(input_str), stdin)) {
        input_str[strcspn(input_str, "\n")] = 0;
        
        char clean_input[100];
        j = 0;
        for (i = 0; input_str[i]; i++) {
            if (input_str[i] != ' ' && input_str[i] != '\t') {
                clean_input[j++] = input_str[i];
            }
        }
        clean_input[j] = '\0';
        
        parse_ll1(clean_input);
    }
    
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}