#include <stdio.h>

int isOperator(char c) {
    return (c=='+' || c=='-' || c=='*' || c=='/' ||
            c=='=' || c=='<' || c=='>' || c=='!' ||
            c=='&' || c=='|' || c==';');
}

int main() {

    char line[200];
    printf("Enter input: ");
    scanf("%[^\n]", line);
    int i;
    for (i = 0; line[i]; i++) {
        if (isOperator(line[i])) {
            printf("Operator: %c\n", line[i]);
        }
    }

    return 0;
}
