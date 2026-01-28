#include <stdio.h>

int isSpecial(char c) {
    return (c=='{' || c=='}' || c=='(' || c==')' ||
            c==';' || c==',' || c=='[' || c==']' || c=='.');
}

int main() {
    char line[200];
    printf("Enter input: ");
    scanf("%[^\n]", line);
    int i;
    for (i = 0; line[i]; i++) {
        if (isSpecial(line[i])) {
            printf("Special Symbol: %c\n", line[i]);
        }
    }

    return 0;
}
