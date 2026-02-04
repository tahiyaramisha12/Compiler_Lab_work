%{
#include "cg.tab.h"
#include <string.h>
%}

%%
"sqrt"      { return SQRT; }
"pow"       { return POW; }
"log"       { return LOG; }
"exp"       { return EXP; }
"sin"       { return SIN; }
"cos"       { return COS; }
"tan"       { return TAN; }
"abs"       { return ABS; }

"+"         { return '+'; }
"-"         { return '-'; }
"*"         { return '*'; }
"/"         { return '/'; }
"%"         { return '%'; }
"="         { return '='; }
","         { return ','; }

"("         { return '('; }
")"         { return ')'; }

[a-zA-Z][a-zA-Z0-9]*   { strcpy(yylval.str, yytext); return ID; }
[0-9]+                 { strcpy(yylval.str, yytext); return NUM; }

\r                     { }
\n                     { return NL; }
[ \t]+                 { }

%%
int yywrap() {
    return 1;
}