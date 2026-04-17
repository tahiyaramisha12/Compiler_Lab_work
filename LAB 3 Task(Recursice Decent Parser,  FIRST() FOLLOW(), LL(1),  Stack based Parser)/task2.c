#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_PRODS 20
#define MAX_RHS 10
#define MAX_LEN 50
#define MAX_NT 10
#define MAX_SET 20

typedef struct {
    char lhs;
    char rhs[MAX_RHS][MAX_LEN];
    int count;
} Production;

Production prods[MAX_PRODS];

char non_terminals[MAX_NT];
int nt_count = 0;

char FIRST[MAX_NT][MAX_SET];
int first_count[MAX_NT];

char FOLLOW[MAX_NT][MAX_SET];
int follow_count[MAX_NT];

char start_symbol;

int get_index(char symbol) {
    int i;
    for (i = 0; i < nt_count; i++)
        if (non_terminals[i] == symbol) return i;
    return -1;
}

int in_set(char set[MAX_SET], int count, char c) {
    int i;
    for (i = 0; i < count; i++)
        if (set[i] == c) return 1;
    return 0;
}

void add_to_set(char set[MAX_SET], int *count, char c) {
    if (!in_set(set, *count, c)) set[(*count)++] = c;
}

void find_first(char symbol) {
    int idx = get_index(symbol);
    if (idx == -1) return;
    if (first_count[idx] > 0) return;

    int i;
    for (i = 0; i < prods[idx].count; i++) {
        char *prod = prods[idx].rhs[i];

        if (prod[0] == '@') {
            add_to_set(FIRST[idx], &first_count[idx], '@');
        } else {
            int j;
            int all_have_epsilon = 1;

            for (j = 0; prod[j]; j++) {
                char ch = prod[j];

                if (!isupper(ch)) {
                    add_to_set(FIRST[idx], &first_count[idx], ch);
                    all_have_epsilon = 0;
                    break;
                } else {
                    int ch_idx = get_index(ch);
                    if (ch_idx == -1) break;

                    find_first(ch);

                    int k;
                    int has_epsilon = 0;
                    for (k = 0; k < first_count[ch_idx]; k++) {
                        if (FIRST[ch_idx][k] != '@')
                            add_to_set(FIRST[idx], &first_count[idx], FIRST[ch_idx][k]);
                        else
                            has_epsilon = 1;
                    }

                    if (!has_epsilon) {
                        all_have_epsilon = 0;
                        break;
                    }
                }
            }

            if (all_have_epsilon && j == strlen(prod))
                add_to_set(FIRST[idx], &first_count[idx], '@');
        }
    }
}

void compute_follow() {
    add_to_set(FOLLOW[get_index(start_symbol)],
               &follow_count[get_index(start_symbol)], '$');

    int changed = 1;
    while (changed) {
        changed = 0;
        int i;
        for (i = 0; i < nt_count; i++) {
            int j;
            for (j = 0; j < prods[i].count; j++) {
                char *prod = prods[i].rhs[j];
                int len = strlen(prod);
int k;
                for (k = 0; k < len; k++) {
                    char B = prod[k];
                    if (!isupper(B)) continue;

                    int B_idx = get_index(B);
                    if (B_idx == -1) continue;

                    int before = follow_count[B_idx];

                    if (k + 1 < len) {
                        char next = prod[k + 1];
                        if (!isupper(next)) {
                            add_to_set(FOLLOW[B_idx], &follow_count[B_idx], next);
                        } else {
                            int next_idx = get_index(next);
                            int m;
                            for (m = 0; m < first_count[next_idx]; m++) {
                                if (FIRST[next_idx][m] != '@')
                                    add_to_set(FOLLOW[B_idx], &follow_count[B_idx], FIRST[next_idx][m]);
                            }

                            int can_be_epsilon = 0;
                            for (m = 0; m < first_count[next_idx]; m++) {
                                if (FIRST[next_idx][m] == '@') {
                                    can_be_epsilon = 1;
                                    break;
                                }
                            }

                            if (can_be_epsilon) {
                                    int m;
                                for (m = 0; m < follow_count[i]; m++)
                                    add_to_set(FOLLOW[B_idx], &follow_count[B_idx], FOLLOW[i][m]);
                            }
                        }
                    } else {
                        int m;
                        for (m = 0; m < follow_count[i]; m++)
                            add_to_set(FOLLOW[B_idx], &follow_count[B_idx], FOLLOW[i][m]);
                    }

                    if (before != follow_count[B_idx]) changed = 1;
                }
            }
        }
    }
}

void print_set(char set[MAX_SET], int count) {
    printf("{ ");
    int i;
    for (i = 0; i < count; i++) {
        printf("%c", set[i]);
        if (i != count - 1) printf(", ");
    }
    printf(" }");
}

int main() {
    int n, i;
    printf("Number of productions: ");
    scanf("%d", &n);
    getchar();

    printf("Enter productions:\n");

    for (i = 0; i < n; i++) {
        char line[MAX_LEN];
        fgets(line, sizeof(line), stdin);
        line[strcspn(line, "\n")] = 0;

        char lhs = line[0];
        char *rhs_start = strchr(line, '=');
        if (rhs_start == NULL) {
            printf("Error: Invalid production format\n");
            return 1;
        }
        rhs_start++;

        while (*rhs_start == ' ') rhs_start++;

        int idx = get_index(lhs);
        if (idx == -1) {
            idx = nt_count;
            non_terminals[nt_count++] = lhs;
            prods[idx].lhs = lhs;
            prods[idx].count = 0;
        }

        strcpy(prods[idx].rhs[prods[idx].count++], rhs_start);
    }

    start_symbol = non_terminals[0];

    for (i = 0; i < nt_count; i++)
        find_first(non_terminals[i]);

    compute_follow();

    printf("\n");
    for (i = 0; i < nt_count; i++) {
        printf("FIRST(%c) = ", non_terminals[i]);
        print_set(FIRST[i], first_count[i]);
        printf("\n");
    }

    printf("\n");
    for (i = 0; i < nt_count; i++) {
        printf("FOLLOW(%c) = ", non_terminals[i]);
        print_set(FOLLOW[i], follow_count[i]);
        printf("\n");
    }

    return 0;
}
