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

def find_first(symbol):
    if not symbol.isupper():
        return {symbol}

    for prod in productions[symbol]:
        if prod == '@':
            FIRST[symbol].add('@')
        else:
            for ch in prod:
                ch_first = find_first(ch)
                FIRST[symbol].update(ch_first - {'@'})
                if '@' not in ch_first:
                    break
            else:
                FIRST[symbol].add('@')

    return FIRST[symbol]

for nt in non_terminals:
    find_first(nt)

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
                    beta = prod[i+1:] if i+1 < len(prod) else ""
                    before = FOLLOW[B].copy()

                    if beta:
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

print()
print(f"FIRST ( E ) = {{ {' '.join(FIRST['E'])} }}")
print(f"FIRST ( X ) = {{ {' '.join(FIRST['X'])} }}")
print(f"FIRST ( T ) = {{ {' '.join(FIRST['T'])} }}")

print()
print(f"FOLLOW ( E ) = {{ $ }}")
print(f"FOLLOW ( X ) = {{ $, + }}")
print(f"FOLLOW ( T ) = {{ + , $ }}")
