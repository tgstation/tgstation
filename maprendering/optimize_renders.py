#/usr/bin/env python
from __future__ import print_function
from distutils.spawn import find_executable
from os import listdir
from os.path import join, isdir, isfile

try:
	import PIL.Image
except:
	print("Unable to import Pillow. Please ensure Pillow is installed by running 'pip install pillow' in a command line.")
	exit()

try:
	import subprocess32 as subprocess # Use subprocess32 if the user has it installed instead.
except:
	import subprocess

optipng = None
renderOutput = "renderoutput"
mapNames = ["BoxStation", "Defficiency", "MetaClub"]

def main():
	global optipng
	optipng = find_executable("optipng")
	if not optipng: # Unable to find optipng executable.
		print("Unable to find optipng executable. Please ensure it is in your PATH.")
		exit()

	for mapname in [join(renderOutput, x) for x in mapNames]:
		if not isdir(mapname):
			continue

		for zlevel in listdir(mapname):
			fullzpath = join(mapname, zlevel)
			if not isdir(fullzpath):
				continue

			for filename in listdir(fullzpath):
				optimize(join(fullzpath, filename))


def optimize(filename):
	print(filename)
	image = PIL.Image.open(filename)
	if image.getcolors(128) == None: # None will happen if the amount is greater than 128.
		print("Reducing colour depth to 128 with Pillow.")
		image = image.quantize(128)
		image.save(filename)
	else:
		print("Colour depth already at or lower than 128 colours.")

	print("Optimizing with optipng.")
	subprocess.call([optipng, filename])

if __name__ == "__main__":
	main()
