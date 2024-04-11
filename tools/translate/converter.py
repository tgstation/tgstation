import git
import json
import re
import os
import hashlib
BUILD_PATH = os.path.join(os.path.dirname(os.path.realpath(__file__)), "..", "..")

repo = git.Repo(BUILD_PATH)
tree = repo.head.commit.tree
if not tree:
    print("No changes")
    exit()
diff = repo.git.diff(tree)
if not diff:
    print("No changes")
    exit()

# Оставляем только стоки, где строки начинаются с "+", "-", "---"
diff = [line for line in diff.split("\n") if line[0] in "+-" and not line.startswith("+++")]

# Собираем в структуру вида:
# {
#   "file": "player.dm",
#   "origin": ["Test", "Test2"],
#   "replace": ["Тест", "Тест2"]
# }
files = []
for line in diff:
    if line.startswith("---"):
        files.append({"file": line[6:], "origin": [], "replace": []})
    elif line.startswith("-"):
        files[-1]['origin'].append(line[1:].strip())
    elif line.startswith("+"):
        files[-1]['replace'].append(line[1:].strip())

# Собираем в структуру для хранения в файле:
# {
#   "files": [
#       {
#           "path": "player.dm",
#           "replaces": [
#               {"original": "Test", "replace": "Тест"},
#               {"original": "Test2", "replace": "Тест2"}
#           ]
#       }
#   ]
# }
jsonStructure = {"files": []}
for item in files:
    originLen = len(item["origin"])
    replaceLen = len(item["replace"])

    if originLen != replaceLen:
        print("Changes not equals")
        print(item)
        exit(1)

    file = {"path": item["file"], "replaces": []}

    for i in range(originLen):
        file["replaces"].append({"original": item["origin"][i], "replace": item["replace"][i]})

    jsonStructure["files"].append(file)

jsonFilePath = os.path.dirname(os.path.realpath(__file__)) + '/ss220replace.json'

# Добавляем новые элементы к текущим в файле
fullTranslation = json.load(open(jsonFilePath, encoding='utf-8'))
for file in jsonStructure['files']:
    fullTranslation["files"].append(file)

# Убираем дубли
hashCache = {}
filteredTranslation = {"files": []}
for file in fullTranslation['files']:
    filteredFile = {"path": file["path"], "replaces": []}
    for replace in file['replaces']:
        hash = hashlib.sha256((file['path'] + replace["original"]).encode("utf-8")).hexdigest()
        if hash in hashCache:
            continue
        hashCache[hash] = hash

        filteredFile["replaces"].append({"original": replace["original"], "replace": replace["replace"]})

    filteredTranslation["files"].append(filteredFile)

with open(jsonFilePath, 'w+', encoding='utf-8') as f:
    json.dump(filteredTranslation, f, ensure_ascii=False, indent=2)

print(f"Added translation for {len(jsonStructure['files'])} files.")
