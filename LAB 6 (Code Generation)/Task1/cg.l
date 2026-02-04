%{
#include "cg.tab.h" 
#include <string.h>
%}

%%
"&&"            { return AND; }
"||"            { return OR; }
"!"             { return NOT; }

"**="           { return POW_ASSIGN; }
"+="            { return ADD_ASSIGN; }
"-="            { return SUB_ASSIGN; }
"*="            { return MUL_ASSIGN; }
"/="            { return DIV_ASSIGN; }
"%="            { return MOD_ASSIGN; }
"//="           { return IDIV_ASSIGN; }

"**"            { return POW; }
"//"            { return IDIV; }

">"             { return GT; }
"<"             { return LT; }

"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }
"%"             { return '%'; }
"="             { return '='; }

"("             { return '('; }
")"             { return ')'; }

[a-zA-Z][a-zA-Z0-9]*   { strcpy(yylval.str, yytext); return ID; }
[0-9]+                 { strcpy(yylval.str, yytext); return NUM; }

\r                     { }
\n                     { return NL; }
[ \t]+                 { }

%%
int yywrap() { 
    return 1; 
}