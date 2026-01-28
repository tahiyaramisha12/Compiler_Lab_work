%{
    #include<stdio.h>
%}

%%

[0-9]+\.[0-9]+    { printf("Floating point number: %s\n", yytext); }
[0-9]+            { printf("Integer number: %s\n", yytext); }
[a-zA-Z]+         { /* Ignore identifiers */ }
[=;]              { /* Ignore assignment and semicolon */ }
[ \t\n]+          { /* Ignore whitespace */ }
.                 { printf("Invalid character: %s\n", yytext); }

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
