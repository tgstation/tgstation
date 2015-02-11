#This script kills the server once a day, at the earliest roundend after 3 PM
#How the server is restarted depends on how your server's service management is set up

import datetime
import os
import time

#3 PM
RESTART_THRESHOLD = 15
LAST_RESTART_FILE = "last_restart"

now = datetime.datetime.now()
curDay = int(now.day)
curHour = int(now.hour)

resfile = open(LAST_RESTART_FILE)
lastrestart = int(resfile.readline())
resfile.close()

if curHour > RESTART_THRESHOLD and lastrestart != curDay:
	resfile = open(LAST_RESTART_FILE, "w+")
	resfile.write(str(curDay))
	resfile.close()
	
	#killall sends TERM by default
	os.system("killall DreamDaemon")
	time.sleep(5)
	#>b-b-but anon, killall won't work on windows
	#stop using a terrible OS
	
	#if you haven't set up DreamDaemon as supervised service using something like DaemonTools  (you really should, byond tends to crash randomly) you'll have to restart it manually

	#DO NOT RESTART THE DAEMON IN THIS PROCESS

	#DreamDaemon waits for this process to exit before the shell() call returns, so it might not react to the killall term signal before this script exits
	#If you have to restart it here, do a fork or start a script that waits for the old daemon to exit before creating a new one
	
