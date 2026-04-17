#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char input_string[100];
char original_input[100];
int index_pos = 0;

/* Function declarations */
void E();
void T();
void X();
void match(char expected);
void error();

/* Match function */
void match(char expected) {
    if (input_string[index_pos] == expected) {
        printf("Match %c\n", expected);
        index_pos++;
    } else {
        error();
    }
}

/* E → T X */
void E() {
    printf("E = TX\n");
    T();
    X();
}

/* X → + T X | ε */
void X() {
    if (input_string[index_pos] == '+') {
        printf("X = + TX\n");
        match('+');
        T();
        X();
    } else {
        printf("X = @\n");
    }
}

/* T → i */
void T() {
    printf("T = i\n");
    match('i');
}

/* Error */
void error() {
    printf("String Rejected\n");
    exit(0);
}

/* Parse */
void parse() {
    printf("Parsing string : %s\n", original_input);
    E();

    if (input_string[index_pos] == '$') {
        printf("String Accepted\n");
    } else {
        error();
    }
}

/* ---------------- MAIN ---------------- */
int main() {
    int j = 0;

    printf("Enter string to parse : ");
    fgets(original_input, sizeof(original_input), stdin);
    original_input[strcspn(original_input, "\n")] = '\0';
    int i = 0;
    /* Convert id → i and remove spaces */
    for (i = 0; original_input[i] != '\0'; i++) {
        if (original_input[i] == 'i' && original_input[i + 1] == 'd') {
            input_string[j++] = 'i';
            i++;
        } else if (original_input[i] != ' ') {
            input_string[j++] = original_input[i];
        }
    }

    /* Append end marker */
    input_string[j++] = '$';
    input_string[j] = '\0';

    parse();
    return 0;
}
