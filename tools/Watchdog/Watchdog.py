import subprocess
import socket
import os
import struct
import time
import urllib
import json
import logging
import logging.handlers
import shutil
import cPickle
import HTMLParser

MONITOR = ('127.0.0.1', 7777)  # IP, port.
RESTART_COMMAND = "C:\\Users\\ss13\\Desktop\\start-testing.bat"  # What shell script restarts SS13?
COMPILE_COMMAND = ""#"C:\\Users\\ss13\\Desktop\\start-testing.bat"  # What shell script should be run to compile SS13?
STATS_FILE = 'C:\\Users\\ss13\\Desktop\\stats.json'  # Where do you want stats.json placed?

MAX_FAILURES = 9
TIMEOUT = 30.0  # 30 seconds
WAIT_FOR_SERVER_RESPONSE = True  # Wait for server to write ready4update.txt before running COMPILE_COMMAND?

LOGPATH = 'C:\\Users\\ss13\\Desktop\\crashlog'  # Where do you want crash.log stored?
GAMEPATH = 'C:\\Users\\ss13\\Desktop\\vgstation13-testing'  # Where is the game directory?
CONFIGPATH = 'C:\\Users\\ss13\Desktop\\vgstation13-testing\\config'  # Where is your current list of config files?

GIT_REMOTE = 'origin'
GIT_BRANCH = 'Bleeding-Edge'

NUDGE_IP  = 'localhost'     # IP to nudge
NUDGE_PORT= 45678           # Port to nudge
NUDGE_ID  = 'Test Watchdog' # ID tag (use the same as the server, looks better)
NUDGE_KEY = 'asdfasdfasdf'              # PASSCODE USED ON THE BOT!

def send_nudge(message):
	try:
		data = {}
		
		data['key'] = NUDGE_KEY
		data['id'] = NUDGE_ID
		data['channel'] = 'nudges'
		data['data'] = message
		
		pickled = cPickle.dumps(data)
		s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		s.connect((NUDGE_IP, NUDGE_PORT))
		s.send(pickled)
		s.close()
	except socket.error as e:
		print(str(e))
		return

def git_commit():
	try:
		rev = subprocess.Popen(['git', 'rev-parse', '--short', 'HEAD'], stdout=subprocess.PIPE).communicate()[0][:-1]
		if rev:
			return rev.decode('utf-8')
	except Exception as e:
		print(e)
		pass
	return '[UNKNOWN]'

def git_branch():
	try:
		branch = subprocess.Popen(["git", "rev-parse", "--abbrev-ref", 'HEAD'], stdout=subprocess.PIPE).communicate()[0][:-1]
		if branch:
			return branch.decode('utf-8')
	except Exception as e:
		print(e)
		pass
	return '[UNKNOWN]'
	
def Compile(serverState):
	global waiting_for_next_commit
	currentCommit = git_commit()
	currentBranch = git_branch()
	
	# Compile
	log.info('Code is at {0} ({1}).  Triggering compile.'.format(currentCommit, currentBranch))
	stdout, stderr = subprocess.Popen(COMPILE_COMMAND, shell=True, stdout=subprocess.PIPE).communicate()
	failed = False
	if stdout:
		for line in stdout.split('\n'):
			if 'error:' in line:
				send_nudge('COMPILE ERROR: {0}'.format(line))
				failed = True
				logging.error(line)
			else:
				logging.info(line)
				
	if failed:
		send_nudge('Compile failed. Waiting for next commit.')
		log.info('Compile failed. Waiting for next commit.')
		waiting_for_next_commit = True
		return
	next_nudge = 'Update completed. Restarting...'
	if waiting_for_next_commit:
		next_nudge = 'Update completed, and successfully compiled! Restarting...'
		waiting_for_next_commit = False
	# Update MOTD
	inputRules = os.path.join(CONFIGPATH, 'motd.txt')
	outputRules = os.path.join(GAMEPATH, 'config', 'motd.txt')
	with open(inputRules, 'r') as template:
		with open(outputRules, 'w') as motd:
			for _line in template:
				line = _line.format(GIT_BRANCH=GIT_BRANCH, GIT_REMOTE=GIT_REMOTE, GIT_COMMIT=currentCommit)
				motd.write(line)
	lastCommit = currentCommit
	os.chdir(cwd)

	if serverState:
		send_nudge(next_nudge)
		log.info(next_nudge)
	
	# Recheck in a bit to be sure
	lastState = False
	
	subprocess.call(RESTART_COMMAND, shell=True)
	
def PerformServerReadyCheck(serverState):
	global waiting_on_server_response
	global last_response
	if not waiting_on_server_response:
		return
	currentCommit = git_commit()
	currentBranch = git_branch()
	
	updatereadyfile = os.path.join(GAMEPATH, 'data', 'UPDATE_READY.txt')
	serverreadyfile = os.path.join(GAMEPATH, 'data', 'SERVER_READY.txt')
	srf_exists = os.path.isfile(serverreadyfile)
	if not srf_exists and 'players' in last_response:
		srf_exists = last_response['players'] == 0
	nudgemsg = "Server has "
	if (srf_exists):
		nudgemsg += "sent the READY signal."
	elif (not serverState):
		nudgemsg += "exited."
	if srf_exists or not serverState:
		send_nudge(nudgemsg + ' Now recompiling.')
		waiting_on_server_response = False
		if srf_exists:
			os.remove(serverreadyfile)
		if os.path.isfile(updatereadyfile):
			os.remove(updatereadyfile)
		Compile(serverState)

def checkForUpdate(serverState):
	global GIT_REMOTE
	global GIT_BRANCH
	global COMPILE_COMMAND
	global GAMEPATH
	global CONFIGPATH
	global WAIT_FOR_SERVER_RESPONSE
	global lastCommit
	global waiting_on_server_response
	global waiting_for_next_commit
	cwd = os.getcwd()
	os.chdir(GAMEPATH)
	# subprocess.call('git pull -q -s recursive -X theirs {0} {1}'.format(GIT_REMOTE,GIT_BRANCH),shell=True)
	subprocess.call('git fetch -q {0}'.format(GIT_REMOTE), shell=True)
	subprocess.call('git checkout -q {0}/{1}'.format(GIT_REMOTE, GIT_BRANCH), shell=True) 
	currentCommit = git_commit()
	currentBranch = git_branch()
	if currentCommit != lastCommit and lastCommit is not None:
		lastCommit = currentCommit
		send_nudge('Updating server to {GIT_REMOTE}/{GIT_COMMIT}!'.format(GIT_REMOTE=GIT_REMOTE, GIT_COMMIT=currentCommit))
		subprocess.call('git reset --hard {0}/{1}'.format(GIT_REMOTE, GIT_BRANCH), shell=True) 
		subprocess.call('cp -a {0} {1}'.format(CONFIGPATH, GAMEPATH), shell=True)

		# Copy gamemode, if it exists.
		botConfigSource = os.path.join(GAMEPATH, 'config', 'mode.txt')
		botConfigDest = os.path.join(GAMEPATH, 'data', 'mode.txt')
		if os.path.isfile(botConfigSource):
			if os.path.isfile(botConfigDest):
				os.remove(botConfigDest)
				log.warn('rm {0}'.format(botConfigDest))
			shutil.move(botConfigSource, botConfigDest)
			log.warn('mv {0} {1}'.format(botConfigSource, botConfigDest))
	
		if waiting_for_next_commit:
			Compile(serverState)
			return
			
		if WAIT_FOR_SERVER_RESPONSE:
			# if not waiting_on_server_response:
			waiting_on_server_response = True
			send_nudge('Waiting for server to exit.')
			with open(os.path.join(GAMEPATH, 'data', 'UPDATE_READY.txt'), 'w') as updatenotice:
				updatenotice.write('{GIT_REMOTE}/{GIT_BRANCH} {GIT_COMMIT}'.format(GIT_REMOTE=GIT_REMOTE, GIT_COMMIT=currentCommit, GIT_BRANCH=currentBranch))
			PerformServerReadyCheck(serverState)
			return
		else:
			Compile(serverState)
	else:
		PerformServerReadyCheck(serverState)

# Return True for success, False otherwise.
def open_socket():
	# Open TCP socket to target.
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.connect(MONITOR)
	# 30-second timeout
	s.settimeout(300)
	return s
	
# Snippet below from http://pastebin.com/TGhPBPGp
def decode_packet(packet):
	if packet != "":
		if packet[0] == b'\x00' or packet[1] == b'\x83':  # make sure it's the right packet format
			# Actually begin reading the output:
			sizebytes = struct.unpack('>H', packet[2] + packet[3])  # array size of the type identifier and content # ROB: Big-endian!
			# print(repr(sizebytes))
			size = sizebytes[0] - 1  # size of the string/floating-point (minus the size of the identifier byte)
			if packet[4] == b'\x2a':  # 4-byte big-endian floating-point
				unpackint = struct.unpack('f', packet[5] + packet[6] + packet[7] + packet[8])  # 4 possible bytes: add them up together, unpack them as a floating-point
				return unpackint[1]
			elif packet[4] == b'\x06':  # ASCII string
				unpackstr = ''  # result string
				index = 5  # string index
							   
				while (size > 0):  # loop through the entire ASCII string
					size -= 1
					unpackstr = unpackstr + packet[index]  # add the string position to return string
					index += 1
				return unpackstr.replace('\x00', '')
	log.error('UNKNOWN PACKET: {0}'.format(repr(packet)))
	return b''
				
def ping_server(request):
	global last_response
	try:
		# Snippet below from http://pastebin.com/TGhPBPGp
		#==============================================================
		# All queries must begin with a question mark (ie "?players")
		if request[0] != b'?':
			request = b'?' + request
		   
		# --- Prepare a packet to send to the server (based on a reverse-engineered packet structure) --- 
		query = b'\x00\x83' 
		query += struct.pack('>H', len(request) + 6)  # Rob: BIG-endian
		query += b'\x00\x00\x00\x00\x00'
		query += request
		query += b'\x00'
		#==============================================================

		s = open_socket()
		if s is None:
			return False
		
		# print 'Sending query packet...'
		s.sendall(query)
		# print 'Receiving response...'
		data = b''
		while True:
			buf = s.recv(1024)
			data += buf
			szbuf = len(buf)
			# print('<',szbuf)
			if szbuf < 1024:
				break
		s.close()
		
		response = decode_packet(data)
		
		if response is not None:
			response = response.replace('\x00', '')
			# print 'Received: ', response
		
			parsed_response = {}
			reserved_keys = ['ai', 'respawn', 'admins', 'players', 'host', 'version', 'mode', 'enter', 'vote', 'playerlist']
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
			last_response = parsed_response
			# print 'Received: ', repr(parsed_response) #, response
			# {'ai': '1', 'respawn': '0', 'admins': '0', 'players': '0', 'host': '', 'version': '/vg/+Station+13', 'mode': 'secret', 'enter': '1', 'vote': '0'}
			with open(STATS_FILE, 'w') as f:
				json.dump(parsed_response, f)
		else:
			log.error("Received NONE from server!")
			return False
	except socket.timeout:
		log.error("Socket timed out!")
		return False
	except socket.error:
		log.error("Connection lost!")
		print "Unexpected error:", sys.exc_info()[0]
		return False
	return True

if not os.path.isdir(LOGPATH):
	os.makedirs(LOGPATH)
	
logFormatter = logging.Formatter(fmt='%(asctime)s [%(levelname)-8s]: %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p')  # , level=logging.INFO, filename='crashlog.log', filemode='a+')
log = logging.getLogger()
log.setLevel(logging.INFO)

fileHandler = logging.handlers.RotatingFileHandler(os.path.join(LOGPATH, 'crash.log'), maxBytes=1024 * 1024 * 50, backupCount=0)  # 50MB
fileHandler.setFormatter(logFormatter)
log.addHandler(fileHandler)

consoleHandler = logging.StreamHandler()
consoleHandler.setFormatter(logFormatter)
log.addHandler(consoleHandler)

log.info('-----')
log.info('/vg/station Watchdog: Started.')
send_nudge('Watchdog script restarted.')
lastState = True
failChain = 0
firstRun = True
lastCommit = None
lastResponse = {}
cwd = os.getcwd()
os.chdir(GAMEPATH)
lastCommit = git_commit()
currentBranch = git_branch()
waiting_on_server_response = False
waiting_for_next_commit = False
os.chdir(cwd)
log.info('Git repository on branch {1}, commit {0}.'.format(lastCommit, currentBranch))
while True:
	#if waiting_for_next_commit:
		#checkForUpdate(False)
		#if waiting_for_next_commit:
			#time.sleep(50)
			#continue
	if not ping_server(b'?status'):
		# try to start the server again
		#checkForUpdate(False)
		failChain += 1
		if lastState == False:
			if failChain > MAX_FAILURES:
				send_nudge('Watchdog script has failed to restart the server.')
				log.error('Too many failures, quitting!')
				sys.exit(1)
			log.error('Try {0}/{1}...'.format(failChain, MAX_FAILURES))
			send_nudge('Try {0}/{1}...'.format(failChain, MAX_FAILURES))
		else:
			log.error("Detected a problem, attempting restart ({0}/{1}).".format(failChain, MAX_FAILURES))
			send_nudge('Attempting restart ({0}/{1})...'.format(failChain, MAX_FAILURES))
		subprocess.call(RESTART_COMMAND, shell=True)
		time.sleep(50)  # Sleep 50 seconds for a total of almost 2 minutes before we ping again.
		lastState = False
	else:
		if lastState == False:
			log.info('Server is confirmed to be back up and running.')
			send_nudge('Server is back online and responding to queries.')
		if firstRun:
			log.info('Server is confirmed to be up and running.')
			send_nudge('Server is online and responding to queries.')
		#else:
			#checkForUpdate(True)
		
		lastState = True
		failChain = 0
	firstRun = False
	time.sleep(50)  # 50 seconds between "pings".
