import glob
import os
import re
import sys
import hashlib
import platform
import subprocess
from PIL import Image

BUF_SIZE = 65536  # lets read stuff in 64kb chunks!
chop_filename = re.compile(r"^.*(\..+?)$", re.M)
chop_extension = re.compile(r"^(.*)\..+?$", re.M)

def get_file_hash(path):
    path_suffix = re.sub(chop_filename, r"\1", path, count = 1)
    if path_suffix == ".dmi" or path_suffix == ".png":
        return hash_dmi(path)
    else:
        return hash_file(path)

def hash_dmi(path):
    md5 = hashlib.md5()

    dmi = Image.open(path)
    dmi.load()  # Needed only for .png EXIF data (see citation above)
    dmi_metadata = dmi.info['Description']
    md5.update(dmi_metadata.encode('utf-8'))
    md5.update(f'{list(dmi.getdata())}'.encode('utf-8'))
    return md5.hexdigest()

def hash_file(path):
    md5 = hashlib.md5()

    with open(path, 'rb') as f:
        while True:
            data = f.read(BUF_SIZE)
            if not data:
                break
            md5.update(data)

    return md5.hexdigest()

pass_count = 0
fail_count = 0
output_hash = {}
for cutter_template in glob.glob("..\\..\\icons\\**\*.toml", recursive = True):
    resource_name = re.sub(chop_extension, r"\1", cutter_template, count = 1)
    if not os.path.isfile(resource_name):
        print(f"::error template={cutter_template} exists but lacks a matching resource file ({resource_name})")
        fail_count += 1
        continue

    output_name = re.sub(chop_extension, r"\1.dmi", resource_name, count = 1)
    if not os.path.isfile(output_name):
        print(f"::error template={cutter_template} and resource={resource_name} exist but they lack a matching output={output_name}. (Try rebuilding)")
        fail_count += 1
        continue

    output_hash[output_name] = get_file_hash(output_name)

# Execute cutter
if platform.system() == "Windows":
    subprocess.run("..\\build\\build.bat --force-recut --ci icon-cutter")
else:
    subprocess.run("../build/build --force-recut --ci icon-cutter", shell = True)

for output_name in output_hash:
    new_hash = get_file_hash(output_name)
    if output_hash[output_name] == new_hash:
        pass_count += 1
        continue
    fail_count += 1
    print(f"::error output={output_name} and its templates all exist but were not comitted fully compiled")
    failed = True

print(f"{len(output_hash)} templates checked, {pass_count} passed, {fail_count} failed")
if fail_count > 0:
    sys.exit(1)
