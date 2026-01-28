#include <stdio.h>
#include <string.h>
#include <ctype.h>

char keywords[][20] = {
    "int","float","char","double","long","short","return",
    "if","else","while","for","do","void","break","continue"
};

int isKeyword(char *word) {
    int i;
    for (i = 0; i < 15; i++) {
        if (strcmp(word, keywords[i]) == 0)
            return 1;
    }
    return 0;
}

int isIdentifier(char *lex) {
    if (!isalpha(lex[0]) && lex[0] != '_') return 0;
    int i;
    for (i = 1; lex[i] != '\0'; i++) {
        if (!isalnum(lex[i]) && lex[i] != '_') return 0;
    }
    return 1;
}

int isNumber(char *lex) {
    int dot = 0;
    int i;
    for (i = 0; lex[i] != '\0'; i++) {
        if (lex[i] == '.') dot++;
        else if (!isdigit(lex[i])) return 0;
    }
    return dot <= 1;
}

int isOperator(char *lex) {
    char ops[][3] = {"+","-","*","/","%","=","==","!=",
                     ">","<",">=","<=","&&","||","!"};
    int i;
    for (i=0;i<15;i++){
        if (strcmp(lex, ops[i])==0) return 1;
    }
    return 0;
}

int isSpecial(char c) {
    char sp[] = "{}();,[]";
    int i;
    for (i = 0; sp[i] != '\0'; i++) {
        if (c == sp[i]) return 1;
    }
    return 0;
}

int main() {
    char line[500];
    printf("Enter input:\n");
    fgets(line, sizeof(line), stdin);

    char token[100];
    int j = 0;

    printf("\nTokens:\n");
    int i;
    for (i = 0; line[i] != '\0'; i++) {

        if (line[i] == '"') {
            j = 0;
            token[j++] = line[i++];
            while (line[i] != '"' && line[i] != '\0') {
                token[j++] = line[i++];
            }
            token[j++] = '"';
            token[j] = '\0';
            printf("<string_literal , %s>\n", token);
            continue;
        }

        if (line[i] == '/' && line[i+1] == '/') {
            printf("<comment , //...>\n");
            break;
        }

        if (isSpecial(line[i])) {
            printf("<special_symbol , %c>\n", line[i]);
            continue;
        }

        if (isalnum(line[i]) || line[i]=='_' || line[i]=='.') {
            j = 0;
            while (isalnum(line[i]) || line[i]=='_' || line[i]=='.') {
                token[j++] = line[i++];
            }
            token[j] = '\0';
            i--;

            if (isKeyword(token))
                printf("<keyword , %s>\n", token);
            else if (isNumber(token))
                printf("<constant , %s>\n", token);
            else if (isIdentifier(token))
                printf("<identifier , %s>\n", token);
            else
                printf("<invalid , %s>\n", token);

            continue;
        }

        if (!isspace(line[i])) {
            char op[3] = { line[i], line[i+1], '\0' };

            if (isOperator(op)) {
                printf("<operator , %s>\n", op);
                i++;
            }
            else {
                char op2[2] = { line[i], '\0' };
                if (isOperator(op2))
                    printf("<operator , %s>\n", op2);
            }
        }
    }

    return 0;
}
