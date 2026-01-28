%{
#include "parser.tab.h"
#include <stdio.h>
%}

%%

"if"        { return IF; }
"else"      { return ELSE; }

"("         { return LPAREN; }
")"         { return RPAREN; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }

";"         { return SEMI; }
"="         { return ASSIGN; }
"<"         { return LT; }
"+"         { return PLUS; }
"/"         { return DIV; }

[0-9]+      { return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { return ID; }

[ \t\r\n]+  ;   /* ignore whitespace */

.           { return yytext[0]; }

%%

int yywrap() {
    return 1;
}
