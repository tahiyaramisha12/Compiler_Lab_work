#include <stdio.h>
#include <ctype.h>

int main() {
    FILE *fo;
    char input[1000], ch;
    int characters = 0, words = 0, lines = 0;
    int w = 0;

    fo = fopen("loren.txt", "r");
    if (fo == NULL) {
        printf("Error opening file.\n");
        return 1;
    }

    while ((ch = fgetc(fo)) != EOF) {
        characters++;

        if (ch == '\n')
            lines++;

        if (isspace(ch)) {
            w = 0;
        } else {
            if (w == 0) {
                words++;
            }
            w = 1;
        }
    }

    fclose(fo);

    printf("Characters: %d\n", characters);
    printf("Words: %d\n", words);
    printf("Lines: %d\n", lines);

    return 0;
}


