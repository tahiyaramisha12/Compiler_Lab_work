%{
      #include<stdio.h>
      int error_count = 0;
      int line_num = 1;
%}

%x COMMENT

%%

"/*"                            {BEGIN(COMMENT);}
<COMMENT>"*/"                   {BEGIN(INITIAL);}
<COMMENT><<EOF>>                {
    printf("ERROR: Unclosed comment - reached end of file\n");
    error_count++;
    return 0;
}
<COMMENT>\n                     {line_num++;}
<COMMENT>.                      {/* consume comment content */}

\"[^"\n]*\"                     {/* Valid string literal */}
\"[^"\n]*                       {
    printf("ERROR: Unterminated string: %s\n", yytext);
    error_count++;
}

"int"|"float"|"char"|"double"|"void"|"if"|"else"|"while"|"for"|"return"    {/* Valid keywords */}

[a-zA-Z_][a-zA-Z0-9_]*          {/* Valid identifier */}

[0-9]+[a-zA-Z_][a-zA-Z0-9_]*    {
    printf("ERROR: Invalid identifier (starts with digit): %s\n", yytext);
    error_count++;
}

[a-zA-Z_][a-zA-Z0-9_]*[@$#]+[a-zA-Z0-9_]*   {
    printf("ERROR: Invalid identifier (contains special character): %s\n", yytext);
    error_count++;
}

[a-zA-Z_][a-zA-Z0-9_]*-[a-zA-Z0-9_]+   {
    printf("ERROR: Invalid identifier (contains hyphen): %s\n", yytext);
    error_count++;
}

[@$#]                           {
    printf("ERROR: Invalid character in identifier: %s\n", yytext);
    error_count++;
}

[0-9]+\.[0-9]+                  {/* Valid float constant */}
[0-9]+                          {/* Valid integer constant */}

"+"|"-"|"*"|"/"|"%"|"="|"=="|"!="|"<"|">"|"<="|">="|"&&"|"||"|"!"|"++"|"--"    {/* Valid operators */}

";"|","|"("|")"|"{"|"}"|"["|"]"    {/* Valid special symbols */}

\n                              {line_num++;}
[ \t]+                          {/* Ignore whitespace */}

.                               {
    printf("ERROR: Invalid character: %s\n", yytext);
    error_count++;
}

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