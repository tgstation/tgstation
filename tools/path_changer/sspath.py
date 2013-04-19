import os
import string
import sys

#
# syntax: sspath.py (index_file) (project root directory)
#
# The function of this file is to go through every code file
# and replace all instances of X with Y.
#
# The index file should contain an arbitrary number of lines in the form:
# oldpath newpath
#
# Because, in some places, typepaths are in the arguments list as (obj/item/bluh) and not /obj/item/bluh,
# you will want all typepaths in the index file to NOT start with a /, or you will just get more compile errors.
#
# Speaking of, you will notice that the first time this is used (at all on the codebase) it does not compile.
# Many attackby()s assume obj/item/weapon/W and use W:variable.  The compiler apparently does check that there is
# a possible target for : in this case, and refuses now that those typepaths are no longer under item/weapon.
#

# constants
target_extensions = [ ".dm", ".dmm" ]
ignore_extensions = [ ".dmi", ".dmb", ".dmf", ".dms", ".dme" ]

# functions
def valid_file(filename):
	for pattern in ignore_extensions:
		if string.rfind(filename, pattern) != -1:
			return False
	
	for pattern in target_extensions:
		if string.rfind(filename,pattern) != -1:
			return True
	
	return False
def get_files(dir):
	filelist = list()
	for root, subfolders, files in os.walk(dir):
		for filename in files:
			if not valid_file(filename):
				continue
			path = os.path.join(root,filename)
			filelist += [path]
	return filelist
		
def run(index_filename, target_dir):
	index = open(index_filename,"rU")
	keylist = index.readlines()
	dictionary = list()
	print "Paths to be changed:"
	for str in keylist:		
		temp = string.strip(str)
		temp = string.split(temp,' ')
		if len(temp) == 2:
			dictionary += [temp]
			print temp[0].ljust(40) + "-> " + temp[1]
	raw_input("Press enter to continue")
		
	allfiles = 	get_files(target_dir)
	for filename in allfiles:
		print filename
		buffer = ""
		with open(filename,"r") as infile:
			buffer = infile.read()
			for old, new in dictionary:
				buffer = string.replace(buffer,old,new)
		with open(filename, "w") as outfile:
			outfile.write(buffer)
			outfile.flush()

# execute the script if called with arguments
if len(sys.argv) == 3:
	run(sys.argv[1], sys.argv[2])
