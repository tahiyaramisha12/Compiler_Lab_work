#include <stdio.h>
#include <string.h>

char *keywords[] = {
    "int","float","char","double","long","short",
    "if","else","for","while","return","void"
};

int isKeyword(char *word) {
    int i;
    for (i = 0; i < 12; i++) {
        if (strcmp(word, keywords[i]) == 0)
            return 1;
    }
    return 0;
}

int main() {
    char line[200];
    printf("Enter input: ");
    scanf("%[^\n]", line);

    char *token = strtok(line, " ;,(){}");
    while (token != NULL) {
        if (isKeyword(token))
            printf("%s: Keyword\n", token);

        token = strtok(NULL, " ;,(){}");
    }

    return 0;
}
