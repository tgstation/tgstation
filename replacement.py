import os
import re

regex_msg = re.compile('(\S*)(\s*<<\s*)("(?:.|\n)*")')

list_of_files = []

for subdir, dirs, files in os.walk(os.getcwd()):
    for file in files:
        #print os.path.join(subdir, file)
        filepath = subdir + os.sep + file

        if filepath.endswith(".dm"):
            list_of_files.append(filepath)