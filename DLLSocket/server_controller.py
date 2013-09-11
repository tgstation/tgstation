import subprocess
import socket
import os
import struct
import time
import urllib
import json
import logging
import logging.handlers

MONITOR = ('127.0.0.1',1336) # IP, port.
RESTART_COMMAND="/home/gmod/byond/ss13.sh" # What shell script restarts SS13?
COMPILE_COMMAND="/home/gmod/byond/compile_ss13.sh" # What shell script should be run to compile SS13?
STATS_FILE='/home/gmod/stats.json' # Where do you want stats.json placed?

MAX_FAILURES=3
TIMEOUT=30.0 # 30 seconds

LOGPATH='/home/gmod/byond/crashlogs/' # Where do you want crash.log stored?
GAMEPATH='/home/gmod/byond/tgstation/' # Where is the game directory?
CONFIGPATH='/home/gmod/byond/config/' # Where is your current list of config files?

GIT_REMOTE='origin'
GIT_BRANCH='Bleeding-Edge'

def git_commit():
	try:
		rev = subprocess.Popen(['git','rev-parse','--short','HEAD'], stdout=subprocess.PIPE).communicate()[0][:-1]
		if rev:
			return rev.decode('utf-8')
	except Exception as e:
		print(e)
		pass
	return '[UNKNOWN]'

def git_branch():
	try:
		branch = subprocess.Popen(["git", "rev-parse", "--abbrev-ref",'HEAD'], stdout=subprocess.PIPE).communicate()[0][:-1]
		if branch:
			return branch.decode('utf-8')
	except Exception as e:
		print(e)
		pass
	return '[UNKNOWN]'
	
def checkForUpdate(serverState):
	global GIT_REMOTE,GIT_BRANCH,COMPILE_COMMAND,GAMEPATH,CONFIGPATH,lastCommit
	cwd=os.getcwd()
	os.chdir(GAMEPATH)
	#subprocess.call('git pull -q -s recursive -X theirs {0} {1}'.format(GIT_REMOTE,GIT_BRANCH),shell=True)
	subprocess.call('git fetch -q {0}'.format(GIT_REMOTE),shell=True)
	subprocess.call('git checkout -q {0}/{1}'.format(GIT_REMOTE,GIT_BRANCH),shell=True) 
	currentCommit = git_commit()
	currentBranch = git_branch()
	if currentCommit != lastCommit and lastCommit is not None:
		subprocess.call('git reset --hard {0}/{1}'.format(GIT_REMOTE,GIT_BRANCH),shell=True) 
		subprocess.call('cp -av {0} {1}'.format(CONFIGPATH,GAMEPATH),shell=True)

		# Copy bot config, if it exists.
		botConfigSource=os.path.join(GAMEPATH,'config','CORE_DATA.py')
		botConfigDest=os.path.join(GAMEPATH,'bot','CORE_DATA.py')
		if os.file.exists(botConfigSource):
			if os.file.exists(botConfigDest):
				os.remove(botConfigDest)
				log.warn('RM {0}'.format(botConfigDest))
			shutil.move(botConfigSource,botConfigDest)
			log.warn('move {0} {1}'.format(botConfigSource,botConfigDest))

		# Compile
		log.info('Updated to {0} ({1}).  Triggering compile.'.format(currentCommit,currentBranch))
		subprocess.call(COMPILE_COMMAND,shell=True)

		# Notify the server that we're restarting.
		updateTrigger=os.path.join(GAMEPATH,'data','UPDATE_READY.txt')
		if not os.path.isdir(os.path.dirname(updateTrigger)):
			os.makedirs(os.path.dirname(updateTrigger))

		if serverState:
			log.info('Server updated.')
			with open(updateTrigger,'w') as f:
				f.write('honk')
		else:
			if os.path.isfile(updateTrigger):
				os.remove(updateTrigger)
	# Update MOTD
	inputRules=os.path.join(CONFIGPATH,'motd.txt')
	outputRules=os.path.join(GAMEPATH,'config','motd.txt')
	with open(inputRules,'r') as template:
		with open(outputRules,'w') as motd:
			for _line in template:
				line=_line.format(GIT_BRANCH=GIT_BRANCH,GIT_REMOTE=GIT_REMOTE,GIT_COMMIT=currentCommit)
				motd.write(line)
	lastCommit=currentCommit
	os.chdir(cwd)

# Return True for success, False otherwise.
def open_socket():
	# Open TCP socket to target.
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.connect(MONITOR)
	# 30-second timeout
	s.settimeout(TIMEOUT)
	return s
	
# Snippet below from http://pastebin.com/TGhPBPGp
def decode_packet(packet):
	if packet != "":
		if packet[0] == b'\x00' or packet[1] == b'\x83': # make sure it's the right packet format
			# Actually begin reading the output:
			sizebytes = struct.unpack('>H', packet[2]+packet[3]) # array size of the type identifier and content # ROB: Big-endian!
			#print(repr(sizebytes))
			size = sizebytes[0] - 1 # size of the string/floating-point (minus the size of the identifier byte)
			if packet[4] == b'\x2a': # 4-byte big-endian floating-point
				unpackint = struct.unpack('f', packet[5]+packet[6]+packet[7]+packet[8]) # 4 possible bytes: add them up together, unpack them as a floating-point
				return unpackint[1]
			elif packet[4] == b'\x06': # ASCII string
				unpackstr = '' # result string
				index = 5 # string index
							   
				while (size > 0): # loop through the entire ASCII string
					size -= 1
					unpackstr = unpackstr+packet[index] # add the string position to return string
					index += 1
				return unpackstr.replace('\x00','')
	log.error('UNKNOWN PACKET: {0}'.format(repr(packet)))
	return b''
				
def ping_server(request):
	try:
		# Snippet below from http://pastebin.com/TGhPBPGp
		#==============================================================
		# All queries must begin with a question mark (ie "?players")
		if request[0] != b'?':
			request = b'?' + request
		   
		# --- Prepare a packet to send to the server (based on a reverse-engineered packet structure) --- 
		query = b'\x00\x83' 
		query += struct.pack('>H', len(request) + 6) # Rob: BIG-endian
		query += b'\x00\x00\x00\x00\x00'
		query += request
		query += b'\x00'
		#==============================================================

		s = open_socket()
		if s is None:
			return False
		
		#print 'Sending query packet...'
		s.sendall(query)
		#print 'Receiving response...'
		data = b''
		while True:
			buf = s.recv(1024)
			data += buf
			szbuf = len(buf)
			#print('<',szbuf)
			if szbuf<1024:
				break
		s.close()
		
		response = decode_packet(data)
		
		if response is not None:
			response = response.replace('\x00','')
			#print 'Received: ', response
		
			parsed_response = {}
			reserved_keys=['ai','respawn','admins', 'players', 'host', 'version', 'mode', 'enter', 'vote','playerlist']
			for chunk in response.split('&'):
				dt = chunk.split('=')
				if dt[0] not in reserved_keys:
					if 'playerlist' not in parsed_response:
						parsed_response['playerlist'] = []
					parsed_response['playerlist'] += [ dt[0] ]
				else:
					parsed_response[dt[0]] = ''
					if len(dt) == 2:
						parsed_response[dt[0]] = urllib.unquote(dt[1])
			#print 'Received: ', repr(parsed_response) #, response
			# {'ai': '1', 'respawn': '0', 'admins': '0', 'players': '0', 'host': '', 'version': '/vg/+Station+13', 'mode': 'secret', 'enter': '1', 'vote': '0'}
			with open(STATS_FILE,'w') as f:
				json.dump(parsed_response,f)
		else:
			log.error("Received NONE from server!")
			return False
	except socket.timeout:
		log.error("Socket timed out!")
		return False
	except socket.error:
		log.error("Connection lost!")
		return False
	return True

if not os.path.isdir(LOGPATH):
	os.makedirs(LOGPATH)
	
logFormatter = logging.Formatter(fmt='%(asctime)s [%(levelname)-8s]: %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p') #, level=logging.INFO, filename='crashlog.log', filemode='a+')
log = logging.getLogger()
log.setLevel(logging.INFO)

fileHandler = logging.handlers.RotatingFileHandler(os.path.join(LOGPATH, 'crash.log'), maxBytes=1024*1024*50, backupCount=0) # 50MB
fileHandler.setFormatter(logFormatter)
log.addHandler(fileHandler)

consoleHandler = logging.StreamHandler()
consoleHandler.setFormatter(logFormatter)
log.addHandler(consoleHandler)

log.info('-----')
log.info('/vg/station Watchdog: Started.')
lastState=True
failChain=0
firstRun=True
lastCommit=None
cwd=os.getcwd()
os.chdir(GAMEPATH)
lastCommit=git_commit()
currentBranch=git_branch()
os.chdir(cwd)
log.info('Git repository on branch {1}, commit {0}.'.format(lastCommit,currentBranch))
while True:
	if not ping_server(b'?status'):
		# try to start the server again
		checkForUpdate(False)
		failChain += 1
		if lastState == False:
			if failChain > MAX_FAILURES:
				log.error('Too many failures, quitting!')
				sys.exit(1)
			log.error('Try {0}/{1}...'.format(failChain,MAX_FAILURES))
		else:
			log.error("Detected a problem, attempting restart ({0}/{1}).".format(failChain,MAX_FAILURES))
		subprocess.call(RESTART_COMMAND,shell=True)
		time.sleep(50) # Sleep 50 seconds for a total of almost 2 minutes before we ping again.
		lastState=False
	else:
		if lastState == False:
			log.info('Server is confirmed to be back up and running.')
		if firstRun:
			log.info('Server is confirmed to be up and running.')
		else:
			checkForUpdate(True)
		
		lastState=True
		failChain=0
	firstRun=False
	time.sleep(50) # 50 seconds between "pings".