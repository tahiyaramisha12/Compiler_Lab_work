%{
    #include<stdio.h>
%}

%%

"//".*            { printf("Single-line comment: %s\n", yytext); }
"/*"([^*]|\*+[^*/])*\*+"/"   { printf("Multi-line comment: %s\n", yytext); }
"/*"([^*]|\*+[^*/])*          { printf("Lexical error: Unterminated multi-line comment\n"); }
[ \t\n]+          { /* Ignore whitespace */ }
.                 { /* Ignore everything else */ }

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
