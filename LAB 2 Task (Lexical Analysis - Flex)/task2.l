%{
    #include<stdio.h>
%}

%%
int|float|double|char|void|return|if|else|for|while   { printf("Keyword: %s\n", yytext); }
[a-zA-Z_][a-zA-Z0-9_]*  { /* ignore identifiers */ }
[0-9]+(\.[0-9]+)?       { /* ignore numbers */ }
[ \t\n]+                { /* ignore whitespace */ }
.                       { /* ignore symbols */ }
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
