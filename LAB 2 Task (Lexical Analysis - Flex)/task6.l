%{
    #include<stdio.h>
%}

%%

[\{\}\(\);\,\[\]\.]   { printf("Special symbol: %s\n", yytext); }

[^{}\(\);\[\]\. \t\n]+   { /* Ignore everything else */ }
[ \t\n]+                 { /* Ignore whitespace */ }

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
