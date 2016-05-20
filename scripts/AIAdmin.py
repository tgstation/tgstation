import threading

import datetime
import time
import os
script_dir = os.path.dirname(__file__)
MONTHS = {
	"01":"January",
	"02":"February",
	"03":"March",
	"04":"April",
	"05":"May",
	"06":"June",
	"07":"July",
	"08":"August",
	"09":"September",
	"10":"October",
	"11":"November",
	"12":"December"}
	
WEEKDAYS = {
	0:"Monday",
	1:"Tuesday",
	2:"Wednesday",
	3:"Thursday",
	4:"Friday",
	5:"Saturday",
	6:"Sunday"
}

class RoundHandler(threading.Thread):

	def __init__(self):
		threading.Thread.__init__(self)
		
	def run(self):
		while 1:
			pass

class UserHandler(threading.Thread):

	def __init__(self):
		threading.Thread.__init__(self)
		
	def run(self):
		while 1:
			pass
			
def parseLog(line):
	print(line)
		
def Log_run():
	while 1:
		#Check for newer log
		date = datetime.date.today()
		monthNum = str(date.month)
		if len(str(date.month)) == 1:
			monthNum = "0"+monthNum
			
		dayNum = str(date.day)
		if len(str(date.day)) == 1:
			dayNum = "0"+dayNum
		log = open(r"Z:\AIStation\data\logs\{}\{}-{}\{}-{} Attack.log".format(date.year, monthNum, MONTHS[monthNum], dayNum, WEEKDAYS[date.weekday()]), "w+")
		print(log.read())
		log.close()
		time.sleep(5)
	
attacklog = threading.Thread(target=Log_run)
attacklog.run()
attacklog.join()