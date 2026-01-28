#include <stdio.h>
#include <ctype.h>
#include <string.h>

char *keywords[] = {
    "int","float","char","double","if","else","while","for","return","void"
};

int isKeyword(char *word) {
    int i;
    for (i = 0; i < 10; i++)
        if (strcmp(word, keywords[i]) == 0)
            return 1;
    return 0;
}

int isValidIdentifier(char *s) {
    if (!isalpha(s[0]) && s[0] != '_')
        return 0;

    int i;
    for (i = 1; s[i]; i++)
        if (!isalnum(s[i]) && s[i] != '_')
            return 0;

    if (isKeyword(s))
        return 0;

    return 1;
}

int main() {
    char word[50];
    printf("Enter input: ");
    while (scanf("%s", word) != EOF) {
        if (isValidIdentifier(word))
            printf("%s: Valid Identifier\n", word);
        else
            printf("%s: Invalid Identifier\n", word);
    }

    return 0;
}
