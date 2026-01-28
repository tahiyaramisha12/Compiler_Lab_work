#include <stdio.h>
#include <string.h>

int main() {
    char line[300];
    printf("Enter input: ");
    scanf("%[^\n]", line);

    if (strncmp(line, "//", 2) == 0) {
        printf("Single line Comment\n");
    }
    else if (strncmp(line, "/*", 2) == 0 &&
             strlen(line) >= 4 &&
             line[strlen(line)-2] == '*' &&
             line[strlen(line)-1] == '/') {
        printf("Multi line Comment\n");
    }
    else {
        printf("Not a Comment\n");
    }

    return 0;
}
