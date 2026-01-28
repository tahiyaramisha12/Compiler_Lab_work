#include <stdio.h>
#include <ctype.h>
#include <string.h>

int isInteger(char *s) {
    int i;
    for (i = 0; s[i]; i++)
        if (!isdigit(s[i])) return 0;
    return 1;
}

int isFloat(char *s) {
    int dot = 0, e = 0;
    int i;
    for (i = 0; s[i]; i++) {
        if (isdigit(s[i])) continue;

        if (s[i] == '.' && !dot) dot = 1;
        else if ((s[i] == 'e' || s[i] == 'E') && !e) e = 1;
        else return 0;
    }
    return 1;
}

int main() {
    char token[50];
    printf("Enter input: ");
    while (scanf("%s", token) != EOF) {
        if (isInteger(token))
            printf("%s: Integer Constant\n", token);
        else if (isFloat(token))
            printf("%s: Float Constant\n", token);
        else
            printf("%s: Invalid Constant\n", token);
    }

    return 0;
}
