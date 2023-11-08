import glob
import os
import re
import sys
import hashlib
import platform
import subprocess

BUF_SIZE = 65536  # lets read stuff in 64kb chunks!

def hash_file(path):
    md5 = hashlib.md5()

    with open(path, 'rb') as f:
        while True:
            data = f.read(BUF_SIZE)
            if not data:
                break
            md5.update(data)

    return md5.hexdigest()

failed = False
chop_extension = re.compile(r"^(.*)\..+?$", re.M)
output_hash = {}
for cutter_template in glob.glob("..\\..\\icons\\**.toml"):
    print(cutter_template)
    resource_name = re.sub(chop_extension, r"\1", cutter_template, count = 1)
    if not os.path.isfile(resource_name):
        print(f"::error template={cutter_template} exists but lacks a matching resource file ({resource_name})")
        failed = True
        continue

    output_name = re.sub(chop_extension, r"\1.dmi", resource_name, count = 1)
    if not os.path.isfile(output_name):
        print(f"::error template={cutter_template} and resource={resource_name} exist but they lack a matching output={output_name}. (Try rebuilding)")
        failed = True
        continue

    output_hash[output_name] = hash_file(output_name)

# Execute cutter
if platform.system() == "Windows":
    subprocess.run("..\\build\\build.bat --force-recut --ci icon-cutter")
else:
    subprocess.run("..\\build\\build --force-recut --ci icon-cutter")


for output_name in output_hash:
    if output_hash[output_name] == hash_file(output_name):
        continue
    print(f"::error template={cutter_template}, resource={resource_name} and output={output_name} all exist but were not comitted fully compiled")
    failed = True

if failed:
    sys.exit(1)
else:
    print(f"All templates pass, {len(output_hash)} files checked")
