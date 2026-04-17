#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_PRODUCTIONS 100
#define MAX_SYMBOLS 26
#define MAX_LEN 50

typedef struct {
    char lhs;
    char rhs[MAX_PRODUCTIONS][MAX_LEN];
    int count;
} Production;

typedef struct {
    char items[MAX_PRODUCTIONS];
    int count;
} Set;

Production productions[MAX_SYMBOLS];
int production_count = 0;
char non_terminals[MAX_SYMBOLS];
int nt_count = 0;

Set FIRST[MAX_SYMBOLS];
Set FOLLOW[MAX_SYMBOLS];

int index_nt(char ch) {
    int i;
    for (i = 0; i < nt_count; i++)
        if (non_terminals[i] == ch)
            return i;
    return -1;
}

void add_to_set(Set *s, char ch) {
    int i;
    for (i = 0; i < s->count; i++)
        if (s->items[i] == ch) return;
    s->items[s->count++] = ch;
}

int set_contains(Set *s, char ch) {
    int i;
    for (i = 0; i < s->count; i++)
        if (s->items[i] == ch) return 1;
    return 0;
}

void union_sets(Set *dest, Set *src) {
    int i;
    for (i = 0; i < src->count; i++)
        add_to_set(dest, src->items[i]);
}

Set first(char symbol);

/* FIRST of an entire RHS string */
Set first_of_string(char *str) {
    Set result;
    int i;
    result.count = 0;

    if (str[0] == '@') {
        add_to_set(&result, '@');
        return result;
    }

    for (i = 0; str[i] != '\0'; i++) {
        Set f = first(str[i]);
        int k;
        for (k = 0; k < f.count; k++)
            if (f.items[k] != '@')
                add_to_set(&result, f.items[k]);
        if (!set_contains(&f, '@'))
            break;
        if (str[i+1] == '\0')
            add_to_set(&result, '@');
    }
    return result;
}

Set first(char symbol) {
    Set s;
    s.count = 0;

    if (!isupper(symbol)) {
        add_to_set(&s, symbol);
        return s;
    }

    int idx = index_nt(symbol);
    if (idx == -1) return s;

    if (FIRST[idx].count > 0)
        return FIRST[idx];

    int p;
    for (p = 0; p < productions[idx].count; p++) {
        char *prod = productions[idx].rhs[p];

        if (prod[0] == '@') {
            add_to_set(&FIRST[idx], '@');
        } else {
            int i;
            for (i = 0; prod[i]; i++) {
                Set f = first(prod[i]);
                int k;
                for (k = 0; k < f.count; k++)
                    if (f.items[k] != '@')
                        add_to_set(&FIRST[idx], f.items[k]);
                if (!set_contains(&f, '@')) break;
                if (prod[i+1] == '\0')
                    add_to_set(&FIRST[idx], '@');
            }
        }
    }
    return FIRST[idx];
}

void compute_follow() {
    int i;
    for (i = 0; i < nt_count; i++)
        FOLLOW[i].count = 0;

    add_to_set(&FOLLOW[0], '$');

    int changed = 1;
    while (changed) {
        changed = 0;
        for (i = 0; i < nt_count; i++) {
            Production p = productions[i];
            int j;
            for (j = 0; j < p.count; j++) {
                char *rhs = p.rhs[j];
                int len = strlen(rhs);
                int k;
                for (k = 0; k < len; k++) {
                    char B = rhs[k];
                    if (!isupper(B)) continue;

                    int idx_B = index_nt(B);
                    if (idx_B == -1) continue;
                    int before = FOLLOW[idx_B].count;

                    /* FIRST of the string after B */
                    char rest[MAX_LEN];
                    if (k + 1 < len)
                        strcpy(rest, rhs + k + 1);
                    else
                        rest[0] = '\0';

                    if (rest[0] == '\0') {
                        /* B is at end: add FOLLOW(LHS) */
                        union_sets(&FOLLOW[idx_B], &FOLLOW[i]);
                    } else {
                        Set f = first_of_string(rest);
                        int n;
                        for (n = 0; n < f.count; n++)
                            if (f.items[n] != '@')
                                add_to_set(&FOLLOW[idx_B], f.items[n]);
                        if (set_contains(&f, '@'))
                            union_sets(&FOLLOW[idx_B], &FOLLOW[i]);
                    }

                    if (FOLLOW[idx_B].count != before) changed = 1;
                }
            }
        }
    }
}

int is_ll1_grammar() {
    int i;
    for (i = 0; i < nt_count; i++) {
        Production p = productions[i];
        int j;
        for (j = 0; j < p.count; j++) {
                int k;
            for (k = j + 1; k < p.count; k++) {
                Set f1 = first_of_string(p.rhs[j]);
                Set f2 = first_of_string(p.rhs[k]);

                Set f1_no_eps = {.count = 0};
                Set f2_no_eps = {.count = 0};
                int a;
                for (a = 0; a < f1.count; a++)
                    if (f1.items[a] != '@')
                        add_to_set(&f1_no_eps, f1.items[a]);

                for (a = 0; a < f2.count; a++)
                    if (f2.items[a] != '@')
                        add_to_set(&f2_no_eps, f2.items[a]);


                for (a = 0; a < f1_no_eps.count; a++) {
                    if (set_contains(&f2_no_eps, f1_no_eps.items[a])) {
                        printf("Conflict: FIRST(%s) and FIRST(%s) both contain '%c'\n",
                               p.rhs[j], p.rhs[k], f1_no_eps.items[a]);
                        return 0;
                    }
                }

                int f1_has_eps = set_contains(&f1, '@');
                int f2_has_eps = set_contains(&f2, '@');

                if (f1_has_eps) {
                        int a;
                    for (a = 0; a < f2_no_eps.count; a++) {
                        if (set_contains(&FOLLOW[i], f2_no_eps.items[a])) {
                            printf("Conflict: %s can derive @, and FIRST(%s) contains '%c' which is in FOLLOW(%c)\n",
                                   p.rhs[j], p.rhs[k], f2_no_eps.items[a], non_terminals[i]);
                            return 0;
                        }
                    }
                }

                if (f2_has_eps) {
                        int a;
                    for (a = 0; a < f1_no_eps.count; a++) {
                        if (set_contains(&FOLLOW[i], f1_no_eps.items[a])) {
                            printf("Conflict: %s can derive @, and FIRST(%s) contains '%c' which is in FOLLOW(%c)\n",
                                   p.rhs[k], p.rhs[j], f1_no_eps.items[a], non_terminals[i]);
                            return 0;
                        }
                    }
                }

                if (f1_has_eps && f2_has_eps) {
                    printf("Conflict: Both productions can derive @\n");
                    return 0;
                }
            }
        }
    }
    return 1;
}

void print_set(Set *s, char *name) {
    printf("%s = { ", name);
    int i;
    for (i = 0; i < s->count; i++) {
        printf("%c", s->items[i]);
        if (i < s->count - 1) printf(", ");
    }
    printf(" }\n");
}

int main() {
    int n;
    printf("Number of productions: ");
    scanf("%d", &n);
    getchar();

    printf("Enter productions:\n");
    int i;
    for (i = 0; i < n; i++) {
        char line[MAX_LEN];
        fgets(line, sizeof(line), stdin);
        line[strcspn(line, "\n")] = 0;

        char *eq = strchr(line, '=');
        if (!eq) continue;
        char lhs = line[0];
        char *rhs = eq + 1;

        while (*rhs == ' ') rhs++;

        int idx = index_nt(lhs);
        if (idx == -1) {
            non_terminals[nt_count++] = lhs;
            idx = nt_count - 1;
            productions[idx].lhs = lhs;
            productions[idx].count = 0;
            production_count++;
        } else {
            idx = index_nt(lhs);
        }
        strcpy(productions[idx].rhs[productions[idx].count++], rhs);
    }

    for (i = 0; i < nt_count; i++)
        first(non_terminals[i]);

    compute_follow();

    printf("\n=== FIRST SETS ===\n");
    for (i = 0; i < nt_count; i++) {
        char name[20];
        sprintf(name, "FIRST(%c)", non_terminals[i]);
        print_set(&FIRST[i], name);
    }

    printf("\n=== FOLLOW SETS ===\n");
    for (i = 0; i < nt_count; i++) {
        char name[20];
        sprintf(name, "FOLLOW(%c)", non_terminals[i]);
        print_set(&FOLLOW[i], name);
    }

    printf("\n=== LL(1) CHECK ===\n");
    if (is_ll1_grammar())
        printf("Grammar is LL(1)\n");
    else
        printf("Grammar is not LL(1)\n");

    return 0;
}
