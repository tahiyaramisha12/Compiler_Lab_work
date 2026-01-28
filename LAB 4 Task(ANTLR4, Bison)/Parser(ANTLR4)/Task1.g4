grammar Task1;

expr
    : expr '^' expr
    | expr '*' expr
    | expr '/' expr
    | expr '+' expr
    | expr '-' expr
    | '(' expr ')'
    | NUMBER
    | ID
    ;

NUMBER
    : [0-9]+ ('.' [0-9]+)?
    ;

ID
    : [a-zA-Z_] [a-zA-Z0-9_]*
    ;

WS
    : [ \t\r\n]+ -> skip
    ;
