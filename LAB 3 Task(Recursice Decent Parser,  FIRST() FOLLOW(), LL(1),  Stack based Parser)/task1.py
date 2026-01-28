input_string = ""
index = 0


def match(expected):
    global index
    if index < len(input_string) and input_string[index] == expected:
        print(f"Match {expected}")
        index += 1
    else:
        error()


def E():
    print("E = TX")
    T()
    X()


def X():
    global index
    if index < len(input_string) and input_string[index] == '+':
        print("X = + TX")
        match('+')
        T()
        X()
    else:
        print("X = @")


def T():
    print("T = i")
    match('i')


def error():
    print("String Rejected")
    exit(0)


def parse():
    print(f"Parsing string : {original_input}")
    E()
    if index < len(input_string) and input_string[index] == '$':
        print("String Accepted")
    else:
        error()

original_input = input("Enter string to parse : ")

input_string = original_input.replace("id", "i").replace(" ", "")

parse()
