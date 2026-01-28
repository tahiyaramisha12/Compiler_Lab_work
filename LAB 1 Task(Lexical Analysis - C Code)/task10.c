#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>

bool isValidIdentifierChar(char c) {
    return isalnum(c) || c == '_';
}

bool isValidIdentifier(char *str) {
    if (str[0] == '\0') return false;

    if (!isalpha(str[0]) && str[0] != '_') {
        return false;
    }
    int i;
    for (i = 1; str[i] != '\0'; i++) {
        if (!isValidIdentifierChar(str[i])) {
            return false;
        }
    }
    return true;
}

char findInvalidChar(char *str) {
    int i;
    for (i = 0; str[i] != '\0'; i++) {
        if (str[i] == '@' || str[i] == '$' || str[i] == '#')
            return str[i];
    }
    return '\0';
}

bool isStringTerminated(char *line, int start) {
    int i = start + 1;
    while (line[i] != '\0') {
        if (line[i] == '"')
            return true;
        i++;
    }
    return false;
}

bool isCommentTerminated(char *line, int start) {
    int i = start + 2;
    while (line[i] != '\0') {
        if (line[i] == '*' && line[i+1] == '/')
            return true;
        i++;
    }
    return false;
}

void extractIdentifier(char *line, int start, char *identifier) {
    int j = 0, i = start;

    while (line[i] != '\0' &&
           (isalnum(line[i]) || line[i] == '_' ||
            line[i] == '@' || line[i] == '$' || line[i] == '#')) {

        identifier[j++] = line[i++];
    }
    identifier[j] = '\0';
}

bool isKeyword(char *word) {
    char *keywords[] = {"int","float","char","double","void","if","else",
                        "while","for","return","break","continue","switch",
                        "case","default","struct","union","typedef","const",
                        "static","extern","auto","register","sizeof"};

    int n = sizeof(keywords)/sizeof(keywords[0]);
    int i;
    for (i = 0; i < n; i++)
        if (strcmp(word, keywords[i]) == 0)
            return true;

    return false;
}

void analyzeLexicalErrors(char *line) {
    int len = strlen(line);
    bool errorFound = false;

    int i;
    for (i = 0; i < len; i++) {

        if (isspace(line[i])) continue;

        if (line[i] == '"') {
            if (!isStringTerminated(line, i)) {
                printf("Error: Unterminated string literal \"");
                int j = i + 1;
                while (line[j] != '\0') {
                    putchar(line[j]);
                    j++;
                }
                printf("\n");
                return;
            }

            i++;
            while (i < len && line[i] != '"') i++;
            continue;
        }

        if (line[i] == '/' && line[i+1] == '*') {

            if (!isCommentTerminated(line, i)) {
                printf("Error: Unclosed comment /*");

                int j = i + 2;
                while (line[j] != '\0') {
                    putchar(line[j]);
                    j++;
                }
                printf("\n");
                return;
            }
            i += 2;
            while (i < len-1) {
                if (line[i] == '*' && line[i+1] == '/') {
                    i++;
                    break;
                }
                i++;
            }
            continue;
        }

        if (isalpha(line[i]) || line[i]=='_' || isdigit(line[i]) ||
            line[i]=='@' || line[i]=='$' || line[i]=='#') {

            char id[100];
            extractIdentifier(line, i, id);

            i += strlen(id) - 1;

            if (isKeyword(id))
                continue;

            if (isdigit(id[0])) {
                printf("Error: Invalid identifier '%s'\n", id);
                return;
            }

            char bad = findInvalidChar(id);
            if (bad != '\0') {
                printf("Error: Invalid character '%c' in identifier %s\n", bad, id);
                return;
            }

            if (!isValidIdentifier(id)) {
                printf("Error: Invalid identifier '%s'\n", id);
                return;
            }
        }
    }

    printf("No lexical errors found.\n");
}

int main() {
    char line[1000];

    printf("Enter input:\n");

    while (1) {
        printf("\n> ");
        if (fgets(line, sizeof(line), stdin) == NULL)
            break;

        line[strcspn(line, "\n")] = 0;

        if (strcmp(line, "exit") == 0)
            break;

        if (strlen(line) == 0)
            continue;

        analyzeLexicalErrors(line);
    }

    printf("\nProgram terminated.\n");
    return 0;
}
