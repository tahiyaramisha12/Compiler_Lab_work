%{
    #include<stdio.h>
%}

%%

"=="            { printf("Relational operator: %s\n", yytext); }
"!="            { printf("Relational operator: %s\n", yytext); }
">="            { printf("Relational operator: %s\n", yytext); }
"<="            { printf("Relational operator: %s\n", yytext); }
">"             { printf("Relational operator: %s\n", yytext); }
"<"             { printf("Relational operator: %s\n", yytext); }
"="             { printf("Assignment operator: %s\n", yytext); }
"+"             { printf("Arithmetic operator: %s\n", yytext); }
"-"             { printf("Arithmetic operator: %s\n", yytext); }
"*"             { printf("Arithmetic operator: %s\n", yytext); }
"/"             { printf("Arithmetic operator: %s\n", yytext); }
"%"             { printf("Arithmetic operator: %s\n", yytext); }
"&&"            { printf("Logical operator: %s\n", yytext); }
"||"            { printf("Logical operator: %s\n", yytext); }
"!"             { printf("Logical operator: %s\n", yytext); }

[a-zA-Z0-9]+   { /* Ignore identifiers and numbers */ }
[ \t\n() ;]+   { /* Ignore whitespace, parentheses, semicolons */ }

%%

int yywrap(){
    return 1;
}

int main(){
    FILE *f = fopen("input.txt","r");
    if(!f){
        printf("Cannot open the file\n");
        return 0;
    }
    yyin = f;
    yylex();
    fclose(f);
    return 0;
}
