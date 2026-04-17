%{
    #include <stdio.h>
    #include <string.h>
    #include <ctype.h>

    int valid_username(const char *s) {
        int len = strlen(s);
        int i, has_dot = 0;

        if (len < 5 || len > 15) return 0;
        if (!isalpha(s[0])) return 0;

        for (i = 0; i < len; i++) {
            if (!isalnum(s[i]) && s[i] != '.') return 0;
            if (s[i] == '.') has_dot = 1;
        }
        return has_dot;
    }

    int valid_password(const char *s) {
        int len = strlen(s);
        int i, has_digit = 0, has_special = 0;

        if (len < 8) return 0;
        if (isdigit(s[0])) return 0;

        for (i = 0; i < len; i++) {
            if (isdigit(s[i])) has_digit = 1;
            if (s[i] == '@' || s[i] == '#' || s[i] == '$') has_special = 1;
        }
        return (has_digit && has_special);
    }
%}

%%

[^\n]+ {
    char username[100], password[100];
    char *token = strtok(yytext, " \t");
    
    if (token != NULL) {
        strcpy(username, token);
        token = strtok(NULL, " \t");
        if (token != NULL) {
            strcpy(password, token);
            
            if (!valid_username(username)) {
                printf("Invalid username\n");
            } else if (!valid_password(password)) {
                printf("Invalid password\n");
            } else {
                printf("Valid credentials\n");
            }
        }
    }
}

\n { /* ignore */ }

%%

int yywrap() { return 1; }

int main(int argc, char *argv[]) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) {
            printf("Cannot open the file %s\n", argv[1]);
            return 1;
        }
        yyin = f;
    }
    
    yylex();
    
    if (argc > 1) {
        fclose(yyin);
    }
    
    return 0;
}