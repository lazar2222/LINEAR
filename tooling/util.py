def smart_split(string: str, remove_empty: bool = True) -> list:
    result = []
    current = ""
    quote_char = None

    i = 0
    while i < len(string):
        if string[i] == "\\" and i + 1 < len(string) and string[i + 1] in ["\\", "\"", "\'"]:
            current += string[i + 1]
            i += 1
        elif string[i] in ["\"", "\'"] and quote_char is None:
            quote_char = string[i]
        elif string[i] in ["\"", "\'"] and quote_char == string[i]:
            quote_char = None
        elif string[i].isspace() and quote_char is None:
            if not remove_empty or current:
                result.append(current.strip())
            current = ""
        else:
            current += string[i]
        i += 1

    if not remove_empty or current:
        result.append(current.strip())
    if quote_char is not None:
        raise ValueError(f"Unclosed quote in string: {string}")

    return result

def parse_args(args: list) -> dict:
    result = {}
    last_flag = ""

    for arg in args:
        if arg.startswith("-"):
            last_flag = arg.lstrip("-")
            if last_flag not in result:
                result[last_flag] = []
        else:
            if last_flag not in result:
                result[last_flag] = []
            result[last_flag].append(arg)

    return result
