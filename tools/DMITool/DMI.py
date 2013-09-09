"""
DMI SPLITTER-UPPER THING

Makes merging sprites a hell of a lot easier.
by N3X15 <nexis@7chan.org>

Requires PIL and apng.py (included)
Written for Python 2.7.
"""

import sys, os, traceback, fnmatch, argparse

from DMI import DMI

args = ()
	
def main():
	opt = argparse.ArgumentParser()  # version='0.1')
	opt.add_argument('-p', '--suppress-post-processing', dest='suppress_post_process', default=False, action='store_true')
	command = opt.add_subparsers(help='The command you wish to execute', dest='MODE')
	
	_disassemble = command.add_parser('disassemble', help='Disassemble a single DMI file to a destination directory')
	_disassemble.add_argument('file', type=str, help='The DMI file to disassemble.', metavar='file.dmi')
	_disassemble.add_argument('destination', type=str, help='The directory in which to dump the resulting images.', metavar='dest/')
	
	_disassemble_all = command.add_parser('disassemble-all', help='Disassemble a directory of DMI files to a destination directory')
	_disassemble_all.add_argument('source', type=str, help='The DMI files to disassemble.', metavar='source/')
	_disassemble_all.add_argument('destination', type=str, help='The directory in which to dump the resulting images.', metavar='dest/')
	
	_compile = command.add_parser('compile', help='Compile a .dmi.mak file')
	_compile.add_argument('makefile', type=str, help='The .dmi.mak file to compile.', metavar='file.dmi.mak')
	_compile.add_argument('destination', type=str, help='The location of the resulting .dmi file.', metavar='file.dmi')
	
	_compare = command.add_parser('compare', help='Compare two DMI files and note the differences')
	_compare.add_argument('theirs', type=str, help='One side of the difference', metavar='theirs.dmi')
	_compare.add_argument('mine', type=str, help='The other side.', metavar='mine.dmi')
	
	_compare_all = command.add_parser('compare-all', help='Compare two DMI files and note the differences')
	_compare_all.add_argument('theirs', type=str, help='One side of the difference', metavar='theirs/')
	_compare_all.add_argument('mine', type=str, help='The other side.', metavar='mine/')
	# compare.add_argument('diff',type=str,help='The difference report location',metavar='report.txt', nargs='?')
	"""
	opt.add_argument('-d', '--disassemble',		dest='disassemble', 	type=str, nargs=2, action=ModeAction, help='Disassemble a single .dmi file to a destination.', metavar='file.dmi dest/')
	opt.add_argument('-D', '--disassemble-all',	dest='disassemble_all', type=str, nargs=2, action=ModeAction, help='Disassemble a directory of DMI files recursively to a destination.', metavar='dmi_files/ dest/')
	opt.add_argument('-c', '--compile', 		dest='make_dmi',		type=str, nargs=2, action=ModeAction, help='Compile a .dmi.mak file to a DMI.', metavar='my.dmi.mak my.dmi')
	opt.add_argument('-c', '--compile', 		dest='make_dmi',		type=str, nargs=2, action=ModeAction, help='Compile a .dmi.mak file to a DMI.', metavar='my.dmi.mak my.dmi')
	"""
	
	args = opt.parse_args()
	print(args)
	if args.MODE == 'compile':
		make_dmi(args.makefile, args.destination, args)
	if args.MODE == 'compare':
		compare(args.theirs, args.mine, args, sys.stdout)
	if args.MODE == 'compare-all':
		compare_all(args.theirs, args.mine, args)
	elif args.MODE == 'disassemble':
		disassemble(args.file, args.destination, args)
	elif args.MODE == 'disassemble-all':
		disassemble_all(args.source, args.destination, args)
	else:
		print('!!! Error, unknown MODE=%r' % args.MODE)

class ModeAction(argparse.Action):
	def __call__(self, parser, namespace, values, option_string=None):
		# print('%s %s %s' % (namespace, values, option_string))
		namespace.MODE = self.dest
		namespace.args = values

def make_dmi(path, dest, parser):
	if(os.path.isfile(path)):
		dmi = None
		try:
			dmi = DMI(dest)
			dmi.make(path)
			dmi.save(dest)
		except SystemError as e:
			print("!!! Received SystemError in %s, halting: %s" % (dmi.filename, traceback.format_exc(e)))
			print('# of cells: %d' % len(dmi.states))
			print('Image h/w: %s' % repr(dmi.size))
			sys.exit(1)
		except Exception as e:
			print("Received error, continuing: %s" % traceback.format_exc())

def disassemble(path, to, parser):
	print('\tD %s -> %s' % (path, to))
	if(os.path.isfile(path)):
		dmi = None
		try:
			dmi = DMI(path)
			dmi.extractTo(to, parser.suppress_post_process)
		except SystemError as e:
			print("!!! Received SystemError in %s, halting: %s" % (dmi.filename, traceback.format_exc(e)))
			print('# of cells: %d' % len(dmi.states))
			print('Image h/w: %s' % repr(dmi.size))
			sys.exit(1)
		except Exception as e:
			print("Received error, continuing: %s" % traceback.format_exc())

def compare(theirsfile, minefile, parser, reportstream):
	print('\tD %s -> %s' % (theirsfile, minefile))
	theirs = []
	mine = []
	states = []
	if(os.path.isfile(theirsfile)):
		try:
			theirsDMI = DMI(theirsfile)
			theirsDMI.parse()
			theirs = theirsDMI.states
		except SystemError as e:
			print("!!! Received SystemError in %s, halting: %s" % (theirs.filename, traceback.format_exc(e)))
			print('# of cells: %d' % len(theirs.states))
			print('Image h/w: %s' % repr(theirs.size))
			sys.exit(1)
		except Exception as e:
			print("Received error, continuing: %s" % traceback.format_exc())
		for stateName in theirs:
			if stateName not in states:
				states.append(stateName)
	if(os.path.isfile(minefile)):
		try:
			mineDMI = DMI(minefile)
			mineDMI.parse()
			mine = mineDMI.states
		except SystemError as e:
			print("!!! Received SystemError in %s, halting: %s" % (mine.filename, traceback.format_exc(e)))
			print('# of cells: %d' % len(mine.states))
			print('Image h/w: %s' % repr(mine.size))
			sys.exit(1)
		except Exception as e:
			print("Received error, continuing: %s" % traceback.format_exc())
		for stateName in mine:
			if stateName not in states:
				states.append(stateName)
	o = ''
	for state in sorted(states):
		inTheirs = state in theirs
		inMine = state in mine 
		if inTheirs and not inMine:
			o += '\n + {1}'.format(minefile, state) 
		if not inTheirs and inMine:
			o += '\n - {1}'.format(theirsfile, state)
	if o != '': 
		reportstream.write('\n--- {0}'.format(theirsfile))
		reportstream.write('\n+++ {0}'.format(minefile))
		reportstream.write(o)
	

def disassemble_all(in_dir, out_dir, parser):
	print('D_A %s -> %s' % (in_dir, out_dir))
	for root, dirnames, filenames in os.walk(in_dir):
		for filename in fnmatch.filter(filenames, '*.dmi'):
			path = os.path.join(root, filename)
			to = os.path.join(out_dir, path.replace(in_dir, '').replace(os.path.basename(path), ''))
			disassemble(path, to, parser)
	

def compare_all(in_dir, out_dir, parser):
	with open('compare_report.txt', 'w') as report:
		report.write('# DMITool Difference Report: {0} {1}'.format(os.path.abspath(in_dir), os.path.abspath(out_dir)))
		for root, dirnames, filenames in os.walk(in_dir):
			for filename in fnmatch.filter(filenames, '*.dmi'):
				path = os.path.join(root, filename)
				to = os.path.join(out_dir, path.replace(in_dir, '').replace(os.path.basename(path), ''))
				to = os.path.join(to, filename)
				path = os.path.abspath(path)
				to = os.path.abspath(to)
				compare(path, to, parser, report)


if __name__ == '__main__':
	main()
