%{
      #include<stdio.h>
%}
%%
\"[^"\n]*\"                     {printf("Valid string literal: %s\n", yytext);}
\"[^"\n]*                       {printf("Error: Unterminated string: %s\n", yytext);}
'[^'\n]'                        {printf("Valid character constant: %s\n", yytext);}
''                              {printf("Error: Empty character constant: ''\n");}
'[^'\n][^'\n]+'                 {printf("Error: Multiple characters in constant: %s\n", yytext);}
'[^'\n][^'\n]+                  {printf("Error: Unterminated character with multiple chars: %s\n", yytext);}
'[^'\n]                         {printf("Error: Unterminated character constant: %s\n", yytext);}
[ \t\n]+                        {/* Ignore whitespace */}
.                               {/* Ignore other characters */}
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