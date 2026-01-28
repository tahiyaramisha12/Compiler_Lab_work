%{
#include "parser4.tab.h"
#include <stdio.h>
%}

%%
"i"        { return IDENTIFIER; }
"+"        { return PLUS; }
"$"        { return DOLLAR; }
"@"        { return EPSILON; }
[ \t\n]+   ;  /* ignore whitespace */
.          { return yytext[0]; }
%%

int yywrap() {
    return 1;
}