#This script kills the server once a day, at the earliest roundend after 12 PM
#How the server is restarted depends on how your server's service management is set up

import datetime
import os
import time

#12 PM
RESTART_THRESHOLD = 12
LAST_RESTART_FILE = "last_restart"

now = datetime.datetime.now()
curDay = int(now.day)
curHour = int(now.hour)

resfile = open(LAST_RESTART_FILE)
lastrestart = int(resfile.readline())
resfile.close()
print datetime.datetime.now().strftime("%c")
print "onRestart\n"
if curHour > (RESTART_THRESHOLD-1) and lastrestart != curDay:
	resfile = open(LAST_RESTART_FILE, "w+")
	resfile.write(str(curDay))
	resfile.close()
	print "restart at"
	print datetime.datetime.now().strftime("%c")
	print "\n"	
	os.system("svc -t /etc/service/dreamdaemon/")
	#He's dead, Jim	
