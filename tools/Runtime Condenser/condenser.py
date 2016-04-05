#!/usr/bin/env python3
# Runtime Condenser, rewritten in python by tkdrg
# Only the first set of proc, file, usr and src will be kept. The rest is truncated.
# This script is valid on both python2 and python3
runtimes = dict()
infloops = dict()
harddels = dict()


def readFromFile(target='input.txt'):
	global runtimes, infloops, harddels
	f = open(target)

	for line in iter(f.readline, ''):
		if 'Infinite loop suspected' in line or 'Maximum recursion level reached' in line:
			f.readline()  # Throw away the 'If it is not an infinite loop' line
			line = f.readline()
			try:
				i = infloops[line]
				i['num'] += 1
			except KeyError:
				infloops[line] = {'file': f.readline(), 'usr': f.readline(), 'src': f.readline(), 'num': 1}

		elif 'runtime error:' in line:
			try:
				i = runtimes[line]
				i['num'] += 1
			except KeyError:
				runtimes[line] = {'proc': f.readline(), 'file': f.readline(), 'usr': f.readline(), 'src': f.readline(), 'num': 1}

		elif 'Path :' in line:
			try:
				i = harddels[line]
				i['num'] += int(f.readline().split()[2])
			except KeyError:
				harddels[line] = {'num': int(f.readline().split()[2])}


def writeToFile(target='output.txt'):
	global runtimes, infloops, harddels
	f = open(target, 'w')

	f.write('Note: The proc name, file, and usr are all from the FIRST of the identical runtimes. Everything else is cropped.\n\n')
	if len(infloops):
		f.write('Total unique infinite loops: {}\n'.format(len(infloops)))
		f.write('Total infinite loops: {}\n\n'.format(sum((i[1]['num'] for i in infloops))))

	if len(runtimes):
		f.write('Total unique runtimes: {}\n'.format(len(runtimes)))
		f.write('Total runtimes: {}\n\n'.format(sum((i[1]['num'] for i in runtimes))))

	if len(harddels):
		f.write('Total unique hard deletions: {}\n'.format(len(harddels)))
		f.write('Total hard deletions: {}\n\n'.format(sum((i[1]['num'] for i in harddels))))

	if len(infloops):
		f.write('** Infinite loops **\n')
		for t in infloops:
			i = t[1]
			f.write('The following infinite loop has occured {} time(s).\n'.format(i['num']))
			f.write(''.join([t[0], i['file'], i['usr'], i['src']]))
			f.write('\n')

	if len(runtimes):
		f.write('** Runtimes **\n')
		for t in runtimes:
			i = t[1]
			f.write('The following runtime has occured {} time(s).\n'.format(i['num']))
			f.write(''.join([t[0], i['proc'], i['file'], i['usr'], i['src']]))
			f.write('\n')

	if len(harddels):
		f.write('** Hard deletions **\n')
		for t in harddels:
			i = t[1]
			f.write('The following path has failed to GC {} time(s).\n'.format(i['num']))
			f.write('{}\n'.format(t[0]))


if __name__ == '__main__':
	readFromFile()

	runtimes = sorted(runtimes.items(), key=lambda x: x[1]['num'], reverse=True)
	infloops = sorted(infloops.items(), key=lambda x: x[1]['num'], reverse=True)
	harddels = sorted(harddels.items(), key=lambda x: x[1]['num'], reverse=True)

	writeToFile()
