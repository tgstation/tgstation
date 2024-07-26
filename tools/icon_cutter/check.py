import glob
import os
import re
import sys
import hashlib
import platform
import subprocess
from PIL import Image
import numpy as np
import difflib

BUF_SIZE = 65536  # lets read stuff in 64kb chunks!
chop_filename = re.compile(r"^.*(\..+?)$", re.M)
chop_extension = re.compile(r"^(.*)\..+?$", re.M)

def reshape_split(image: np.ndarray, cut_to: tuple):
    img_height, img_width, channels = image.shape

    tile_height, tile_width = cut_to

    tiled_array = image.reshape(img_height // tile_height,
                                tile_height,
                                img_width // tile_width,
                                tile_width,
                                channels)
    tiled_array = tiled_array.swapaxes(1, 2)
    tiled_array = tiled_array.reshape(tile_height, -1, channels)
    return tiled_array

def get_file_hash(path):
    path_suffix = re.sub(chop_filename, r"\1", path, count = 1)
    if path_suffix == ".dmi" or path_suffix == ".png":
        return hash_dmi(path)
    else:
        return hash_file(path)

def hash_dmi(path):
    md5 = hashlib.md5()

    dmi = Image.open(path)
    dmi = dmi.convert('RGBA')
    dmi.load()  # Needed only for .png EXIF data (see citation above)
    dmi_metadata = dmi.info['Description']
    md5.update(dmi_metadata.encode('utf-8'))

    readable_metadata = dict(
        map(lambda entry: (entry[0], entry[1]),
            map(lambda entry : (entry[0].strip(), entry[1].strip()),
                filter(lambda entry: entry[0].strip() == 'width' or entry[0].strip() == 'height',
                    map(lambda entry : entry.split("="), dmi_metadata.split("\n"))))))

    icon_hash = hashlib.md5()
    divided_dmi = reshape_split(np.asarray(dmi), (int(readable_metadata['height']), int(readable_metadata['width'])))
    for i in range(divided_dmi.shape[0]):
        bytes = divided_dmi[1].tobytes()
        md5.update(bytes)
        icon_hash.update(bytes)
    return (md5.hexdigest(), dmi_metadata, icon_hash.hexdigest())

def hash_file(path):
    md5 = hashlib.md5()

    with open(path, 'rb') as f:
        while True:
            data = f.read(BUF_SIZE)
            if not data:
                break
            md5.update(data)

    return (md5.hexdigest(), None, None)

path_to_us = os.path.realpath(os.path.dirname(__file__))
pass_count = 0
fail_count = 0
output_hash = {}
files = []
if platform.system() == "Windows":
    files = glob.glob(f"{path_to_us}\..\\..\\icons\\**\*.toml", recursive = True)
else:
    files = glob.glob(f"{path_to_us}/../../icons/**/*.toml", recursive = True)
for cutter_template in files:
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
    subprocess.run(f"{path_to_us}\..\\build\\build.bat --force-recut --ci icon-cutter")
else:
    subprocess.run(f"{path_to_us}/../build/build --force-recut --ci icon-cutter", shell = True)

for output_name in output_hash:
    old_hash, old_metadata, old_icon_hash = output_hash[output_name]
    new_hash, new_metadata, new_icon_hash = get_file_hash(output_name)
    if old_hash == new_hash:
        pass_count += 1
        continue
    if old_metadata != new_metadata:
        print("Metadata differs!")
        events = ""
        current_op = None
        working = ""
        for index, op in enumerate(difflib.ndiff(old_metadata, new_metadata)):
            in_nothing = False
            if current_op == None:
                current_op = op[0]
            if current_op != op[0]:
                events += f"{current_op*10}\n{working}\n"
                current_op = op[0]
                working = ""
            if op[0]== ' ':
                continue
            working += f"{op[-1]}"
        events += f"{current_op*10}\n{working}\n"
        print(events, end="")
    if old_icon_hash != new_icon_hash:
        print("Icon hashes differ!")
    fail_count += 1
    print(f"::error output={output_name} and its templates all exist but were not comitted fully compiled")

print(f"{len(output_hash)} templates checked, {pass_count} passed, {fail_count} failed", end="")
if fail_count > 0:
    sys.exit(1)
