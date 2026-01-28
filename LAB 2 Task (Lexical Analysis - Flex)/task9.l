%{
      #include<stdio.h>
      int token_num = 1;
      int keyword_count = 0;
      int identifier_count = 0;
      int operator_count = 0;
      int constant_count = 0;
      int special_count = 0;
      int string_count = 0;
      int comment_count = 0;
%}
%%
"int"|"float"|"char"|"double"|"void"|"if"|"else"|"while"|"for"|"return"|"break"|"continue"|"printf"|"scanf"    {
    printf("%d <KEYWORD, %s>\n", token_num++, yytext);
    keyword_count++;
}
[a-zA-Z_][a-zA-Z0-9_]*    {
    printf("%d <IDENTIFIER, %s>\n", token_num++, yytext);
    identifier_count++;
}
[0-9]+\.[0-9]+    {
    printf("%d <CONSTANT, %s>\n", token_num++, yytext);
    constant_count++;
}
[0-9]+    {
    printf("%d <CONSTANT, %s>\n", token_num++, yytext);
    constant_count++;
}
\"[^"\n]*\"    {
    printf("%d <STRING_LITERAL, %s>\n", token_num++, yytext);
    string_count++;
}
"//".* |
"/*"([^*]|\*+[^*/])*\*+"/"    {
    printf("%d <COMMENT, %s>\n", token_num++, yytext);
    comment_count++;
}
"+"|"-"|"*"|"/"|"%"|"="|"=="|"!="|"<"|">"|"<="|">="|"&&"|"||"|"!"|"++"|"--"    {
    printf("%d <OPERATOR, %s>\n", token_num++, yytext);
    operator_count++;
}
";"|","|"("|")"|"{"|"}"|"["|"]"    {
    printf("%d <SPECIAL_SYMBOL, %s>\n", token_num++, yytext);
    special_count++;
}
[ \t\n]+    {/* Ignore whitespace */}
.    {/* Ignore other characters */}
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
    
    printf("\nToken Counts\n");
    printf("Keywords: %d\n", keyword_count);
    printf("Identifiers: %d\n", identifier_count);
    printf("Operators: %d\n", operator_count);
    printf("Constants: %d\n", constant_count);
    printf("Special Symbols: %d\n", special_count);
    printf("String Literals: %d\n", string_count);
    printf("Comments: %d\n", comment_count);
    printf("Total Tokens: %d\n", token_num - 1);
    
    return 0;
}