#include <stdio.h>
#include <string.h>
#include <ctype.h>

void checkStringLiteral(char *line) {
    int len = strlen(line);

    if (line[0] == '"') {
        int closed = 0;
        int i;
        for (i = 1; i < len; i++) {
            if (line[i] == '"' && line[i-1] != '\\') {
                closed = 1;
                break;
            }
        }

        if (closed) {
            printf("Valid string literal: %s\n", line);
        } else {
            printf("Unterminated string literal %s\n", line);
        }
        return;
    }

    if (line[0] == '\'') {
        int closed = 0;
        int charCount = 0;
        int closePos = -1;
        int i;
        for (i = 1; i < len; i++) {
            if (line[i] == '\'' && line[i-1] != '\\') {
                closed = 1;
                closePos = i;
                break;
            }
            if (line[i] != '\\') {
                charCount++;
            }
        }

        if (!closed) {
            printf("Unterminated character constant %s\n", line);
        } else if (closePos == 1) {
            printf("Empty character constant ''\n");
        } else if (charCount > 1) {
            printf("Multiple characters in constant %s\n", line);
        } else {
            printf("Valid character constant: %s\n", line);
        }
        return;
    }
}

int main() {
    char line[1000];
    int lineCount = 0;

    printf("Enter string/character literals:\n");

    while (1) {
        printf("Line %d: ", ++lineCount);
        fgets(line, sizeof(line), stdin);

        line[strcspn(line, "\n")] = 0;

        if (strcmp(line, "END") == 0) {
            break;
        }

        if (strlen(line) == 0) {
            lineCount--;
            continue;
        }

        checkStringLiteral(line);
    }

    return 0;
}
