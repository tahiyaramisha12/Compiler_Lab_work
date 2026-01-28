%{
    #include<stdio.h>
%}

%%
[a-zA-Z_][a-zA-Z0-9_]*    { printf("%s: Valid Identifier\n", yytext); }

[0-9][a-zA-Z0-9_]*        { printf("%s: Invalid Identifier\n", yytext); }

[ ,\t\n]+                { /* ignore separators */ }

.                        { /* ignore other characters */ }
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
    return 0;
}
