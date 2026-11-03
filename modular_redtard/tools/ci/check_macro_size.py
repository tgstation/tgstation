"""Every call of a macro with arguments in the module fits the BYOND of the module's CI.

The CI compiles the module on BYOND 516.1685 (dependencies.sh), local builds on a newer BYOND. A call as long as
GLOBAL_LIST_INIT(rogue_recipe_categories, list(...)) once was (94 747 characters, economy/trade_extra_data.dm) compiles
locally and fails on CI with "missing comma ... list started here" at lines past the end of the file. Build such a value
in a proc instead. Without arguments every .dm of the module is checked; with them, only the given files.
"""
import os
import re
import sys

MODULE = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
REPO = os.path.dirname(MODULE)
DEFINE_ROOTS = (os.path.join(REPO, "code"), MODULE)
# Characters from the macro's name to its closing parenthesis. The longest call known to compile on 516.1685 is 42 243
# characters (code/_globalvars/traits/_traits.dm), and 94 747 did not compile: the limit stays below the known good one.
LIMIT = 40000

DEFINE = re.compile(r"^\s*#define\s+(\w+)\(", re.MULTILINE)
CALL = re.compile(r"\b(\w+)\s*\(")
PAREN = re.compile(r"[()]")
# What opens a comment or a string in code; [ and ] matter only inside an embedded expression of a string.
CODE = re.compile(r'//|/\*|^[ \t]*#[ \t]*(?:warn|error)\b|@\{"|@.|\{"|"|\'|\[|\]', re.MULTILINE | re.DOTALL)
# Kinds of string: what may come up inside it, what closes it and whether it embeds [expressions].
STRINGS = {
    '"': (re.compile(r'\\.|\[|"|\n', re.DOTALL), ('"', "\n"), True),
    '{"': (re.compile(r'\\.|\[|"\}', re.DOTALL), ('"}',), True),
    "'": (re.compile(r"\\.|'|\n", re.DOTALL), ("'", "\n"), False),
    '@{"': (re.compile(r'"\}'), ('"}',), False),
}


def relative(path):
    path = os.path.abspath(path)
    if path.startswith(MODULE + os.sep):
        return os.path.relpath(path, MODULE).replace(os.sep, "/")
    return path.replace(os.sep, "/")


def dm_files(roots):
    for root in roots:
        for folder, _, files in os.walk(root):
            for name in files:
                if name.endswith(".dm"):
                    yield os.path.join(folder, name)


def read(path):
    return open(path, encoding="utf-8", errors="replace").read()


def string_kind(token):
    if token in STRINGS:
        return STRINGS[token]
    # A raw string @x...x: no escapes and no embedded expressions, it ends at the next delimiter.
    return re.compile(re.escape(token[1])), (token[1],), False


def blanked(text):
    """The text with comments and the characters of strings turned into spaces (newlines stay), so that the parentheses
    in them do not count. The code of embedded [expressions] stays, strings inside them are blanked too."""
    ranges = []
    stack = []
    i = 0
    end_of_text = len(text)
    while i < end_of_text:
        top = stack[-1] if stack else None
        if top is not None and top[0] == "string":
            _, pattern, closers, embeds = top
            found = pattern.search(text, i)
            if not found:
                ranges.append((i, end_of_text))
                break
            token = found.group()
            ranges.append((i, found.start()))
            i = found.end()
            if token == "[" and embeds:
                stack.append(["expression", 1])
            elif token in closers:
                stack.pop()
            else:
                ranges.append((found.start(), i))
            continue
        found = CODE.search(text, i)
        if not found:
            break
        token = found.group()
        i = found.end()
        if token == "//" or token.lstrip(" \t").startswith("#"):
            line_end = text.find("\n", i)
            line_end = end_of_text if line_end < 0 else line_end
            ranges.append((found.start(), line_end))
            i = line_end
        elif token == "/*":
            comment_end = text.find("*/", i)
            comment_end = end_of_text if comment_end < 0 else comment_end + 2
            ranges.append((found.start(), comment_end))
            i = comment_end
        elif token in ("[", "]"):
            if top is not None:
                top[1] += 1 if token == "[" else -1
                if top[1] == 0:
                    stack.pop()
        else:
            pattern, closers, embeds = string_kind(token)
            stack.append(("string", pattern, closers, embeds))
    pieces = []
    copied = 0
    for start, end in ranges:
        if end <= start:
            continue
        pieces.append(text[copied:start])
        pieces.append(re.sub(r"[^\n]", " ", text[start:end]))
        copied = end
    pieces.append(text[copied:])
    return "".join(pieces)


def shown(text, call):
    """The call as it begins: the macro and its first argument, GLOBAL_LIST_INIT(rogue_recipe_categories, ...)."""
    first = re.match(r"[^,()\n]{0,60}", text[call.end():]).group().strip()
    return f"{call.group(1)}({first}, ...)" if first else f"{call.group(1)}(...)"


def closing_paren(code, open_at):
    depth = 0
    for paren in PAREN.finditer(code, open_at):
        depth += 1 if paren.group() == "(" else -1
        if depth == 0:
            return paren.end()
    return None


def main(paths):
    macros = set()
    for path in dm_files(DEFINE_ROOTS):
        macros.update(DEFINE.findall(read(path)))
    files = paths or list(dm_files((MODULE,)))
    calls = 0
    longest = (0, "", 0, "")
    errors = []
    for path in files:
        text = read(path)
        code = blanked(text)
        for call in CALL.finditer(code):
            name = call.group(1)
            if name not in macros:
                continue
            calls += 1
            end = closing_paren(code, call.end() - 1)
            if end is None:
                line = code.count("\n", 0, call.start()) + 1
                print(f"Warning: {relative(path)}:{line}: {name}( has no closing parenthesis")
                continue
            size = end - call.start()
            if size > longest[0] or size > LIMIT:
                line = code.count("\n", 0, call.start()) + 1
                if size > longest[0]:
                    longest = (size, relative(path), line, shown(text, call))
                if size > LIMIT:
                    errors.append(f"{relative(path)}:{line}: {shown(text, call)} is {size} characters long, over {LIMIT}")
    for line in errors:
        print(f"Too long for BYOND 516.1685 of CI (build the value in a proc): {line}")
    if errors:
        return 1
    size, where, line, call = longest
    print(f"modular_redtard: {calls} macro calls in {len(files)} file{'' if len(files) == 1 else 's'}, the longest "
          f"{size} characters ({call} at {where}:{line}), within {LIMIT}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
