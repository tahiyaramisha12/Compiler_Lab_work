from collections import defaultdict

n = int(input("Number of productions : "))
print("Enter productions :")

productions = defaultdict(list)
non_terminals = []

for _ in range(n):
    line = input().replace(" ", "")
    lhs, rhs = line.split("=")

    if lhs not in non_terminals:
        non_terminals.append(lhs)

    productions[lhs].append(rhs)

start_symbol = non_terminals[0]

FIRST = defaultdict(set)

def first(symbol):
    if not symbol.isupper():
        return {symbol}

    for prod in productions[symbol]:
        if prod == '@':
            FIRST[symbol].add('@')
        else:
            for ch in prod:
                ch_first = first(ch)
                FIRST[symbol].update(ch_first - {'@'})
                if '@' not in ch_first:
                    break
            else:
                FIRST[symbol].add('@')
    return FIRST[symbol]

for nt in non_terminals:
    first(nt)

FOLLOW = defaultdict(set)
FOLLOW[start_symbol].add('$')

changed = True
while changed:
    changed = False
    for lhs in productions:
        for prod in productions[lhs]:
            for i in range(len(prod)):
                B = prod[i]
                if B.isupper():
                    before = FOLLOW[B].copy()

                    if i + 1 < len(prod):
                        beta = prod[i+1:]
                        first_beta = set()
                        for sym in beta:
                            sym_first = FIRST[sym] if sym.isupper() else {sym}
                            first_beta.update(sym_first - {'@'})
                            if '@' not in sym_first:
                                break
                        else:
                            first_beta.add('@')

                        FOLLOW[B].update(first_beta - {'@'})
                        if '@' in first_beta:
                            FOLLOW[B].update(FOLLOW[lhs])
                    else:
                        FOLLOW[B].update(FOLLOW[lhs])

                    if before != FOLLOW[B]:
                        changed = True

is_ll1 = True

for nt in productions:
    prod_list = productions[nt]

    for i in range(len(prod_list)):
        for j in range(i + 1, len(prod_list)):
            p1, p2 = prod_list[i], prod_list[j]

            first1 = set()
            first2 = set()

            if p1 == '@':
                first1.add('@')
            else:
                first1 = first(p1[0])

            if p2 == '@':
                first2.add('@')
            else:
                first2 = first(p2[0])

            if (first1 - {'@'}) & (first2 - {'@'}):
                is_ll1 = False

            if '@' in first1 and (first2 & FOLLOW[nt]):
                is_ll1 = False
            if '@' in first2 and (first1 & FOLLOW[nt]):
                is_ll1 = False

if is_ll1:
    print("Grammar is LL (1)")
else:
    print("Grammar is not LL (1)")
