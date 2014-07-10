"""
copy_logs.py unclean_logs/ cleaned_logs/
* Strips IPs and CIDs.

"""
import re,os,sys,fnmatch

REG_IP4=re.compile(r'\d+\.\d+\.\d+\.\d+') # Matches IPv4 addresses.

# [04:07:35]ACCESS: Login: N3X15/(N3X15) from 127.0.0.1-1234567890 || BYOND v499
REG_CONNECT=re.compile(r'from [^\|]+\|\| BYOND v([0-9]+)$') # Matches IPv4 addresses.

def fix(in_file, out_file):
	print('   {0} -> {1}'.format(in_file,out_file))
	if os.path.isfile(out_file):
		os.remove(out_file)
	if not os.path.isdir(os.path.dirname(out_file)):
		os.makedirs(os.path.dirname(out_file))
	with open(out_file,'w') as w:
		with open(in_file,'r') as r:
			for line in r:
				line=line.strip('\r\n')
				line=REG_CONNECT.sub('from [NOPE] || BYOND v\g<1>', line)
				line=REG_IP4.sub('[IP CENSORED]', line)
				w.write('{0}\n'.format(line))
def replace_walk(in_dir,out_dir):
	print(' {0} -> {1}'.format(in_dir,out_dir))
	for root, dirnames, filenames in os.walk(in_dir):
		for filename in fnmatch.filter(filenames, '*.log'):
			path = os.path.join(root, filename)
			to = path.replace(in_dir, out_dir).replace(os.path.basename(path), '')
			to = os.path.join(to, filename)
			path = os.path.abspath(path)
			to = os.path.abspath(to)
			fix(path, to)
			
replace_walk(sys.argv[1],sys.argv[2])