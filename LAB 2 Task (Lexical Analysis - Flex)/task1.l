%{
    #include <stdio.h>

    int chars = 0;
    int words = 0;
    int lines = 0;
%}

%%

[^\n \t]+    { words++; chars += yyleng; } 
\n           { chars++; lines++; }          
[ \t]+       { chars += yyleng; }         
%%

int yywrap(){
    return 1;
}

int main(){
    FILE *f = fopen("input.txt", "r");
    if(!f){
        printf("Cannot open the file\n");
        return 0;
    }

    yyin = f;
    yylex();

    printf("\nTotal Characters = %d", chars);
    printf("\nTotal Words = %d", words);
    printf("\nTotal Lines = %d\n", lines);

    return 0;
}
