# -*- coding: utf-8 -*-
# This script is shared under the
# Creative Commons Attribution-ShareAlike 3.0 license (CC BY-SA 3.0)
# Added clause to Attribution:
# - You may not remove or hide the '<Bot_name> who created you?' functionality
# and you may not modify the name given in the response.


#CREDITS
# Author: Skibiliano
# "Foreign" Modules:
# Psyco 2.0 / Psyco 1.6
################# DEBUG STUFF #####################
import sys
import CORE_DATA

import urllib2


import socket
import irchat
   
   
################## END OF DEBUG STUFF ##############
#
# PSYCO
write_to_a_file = False #Only affects psyco
write_youtube_to_file = True #True = YTCV4 will load, false = YTCV3 will load
try:
   import psyco
except ImportError:
   print 'Psyco not installed, the program will just run slower'
   psyco_exists = False
   if write_to_a_file:
      try:
         tiedosto = open("psycodownload.txt","r")
      except:
         tiedosto = open("psycodownload.txt","w")
         tiedosto.write("http://www.voidspace.org.uk/python/modules.shtml#psyco")
         tiedosto.write("\nhttp://psyco.sourceforge.net/download.html")
         tiedosto.close()
         print "Check psycodownload.txt for a link"
      else:
         print "For god's sake, open psycodownload.txt"
         tiedosto.close()
   else:
      print "WINDOWS: http://www.voidspace.org.uk/python/modules.shtml#psyco"
      print "LINUX: http://psyco.sourceforge.net/download.html"
else:
   psyco_exists = True
   
# </PSYCO>
import C_rtd # rtd
import C_srtd # srtd
import C_makequote
import C_maths
import C_eightball #eightball
import C_sarcasticball
import C_heaortai # heaortai
import C_rot13 # rot13
import D_help # everything
import pickle
import Timeconverter
import xkcdparser
import time
import re
import Marakov_Chain
import Namecheck # Namecheck
import Weather
#SLOWER THAN RANDOM.CHOICE
import thread
import random
import Shortname # shortname
import subprocess
import some_but_not_all_2 #sbna2 (sbna)
#import YTCv3 # YTCV2 OUTDATED
import os
import save_load # save, load
from some_but_not_all_2 import sbna2 as sbna
from time import sleep
from random import choice as fsample
from C_rtd import rtd
from C_heaortai import heaortai
from C_srtd import srtd
if write_youtube_to_file:
   from YTCv4 import YTCV4 as YTCV2
else:
   from YTCv3 import YTCV2 #Downgraded version supports Cache disabling, but is slower
from save_load import save,load
if psyco_exists:
   def psyco_bond(func):
      psyco.bind(func)
      return func.__name__+" Psycofied"
   for a in [rtd,srtd,C_heaortai.heaortai,sbna,YTCV2,fsample,C_rot13.rot13,C_eightball.eightball,fsample,
             C_eightball.eightball,C_sarcasticball.sarcasticball,Marakov_Chain.form_sentence,Marakov_Chain.give_data]:
      print psyco_bond(a)

global dictionary
global Name,SName
global allow_callnames,offline_messages,hasnotasked,shortform
## For autoRecv()
global disconnects,channel,conn
## For stop()
global operators
## For replace()
global usable,fixing,curtime
## For target()
global CALL_OFF,logbans
## For check()
global influx
######
autodiscusscurtime = 0
conn = 0
curtime = -999
dance_flood_time = 10
disconnects = 0
responsiveness_delay = 0.5 #500 millisecond delay if no message
trackdance = 0
discard_combo_messages_time = 1 #They are discarded after 1 second.
uptime_start = time.time()
# - - - - -
####
aggressive_pinging = True      # Bring the hammer on ping timeouts
aggressive_pinging_delay = 150 # How often to send a ping
aggressive_pinging_refresh = 2.5 # How long is the sleep between checks
####
allow_callnames = True #Disables NT, call if the variable is False
automatic_youtube_reveal = True
birthday_announced = 0 #Will be the year when it was announced
call_to_action = False
call_me_max_length = 20
CALL_OFF = False
connected = False
dance_enabled = True
comboer = ""
comboer_time = 0
directories = ["fmlquotes","Marakov","memos","suggestions",
               "userquotes","banlog","YTCache","xkcdcache"] #These will be created if they do not exist
debug = True
duplicate_notify = False
enabled = True
fixing = False
fml_usable = True
hasnotasked = True
highlights = False
logbans = True
maths_usable = True
marakov = True
nudgeable = True
offensive_mode = False
offline_messages = True
offline_message_limit = 5 # per user
optimize_fml = True # -CPU usage +Memory usage when enabled.
optimize_greeting = True # +Startup time +Memory usage -CPU usage when enabled
heavy_psyco = True # +Memory +Startup time -CPU usage -CPU time
cache_youtube_links = True
personality_greeter = True
respond_of_course = True #Responds with "Of course!"
respond_khan = False #KHAAAAAAAAN!
silent_duplicate_takedown = True
showquotemakers = False
shortform = True
usable = True
use_sname = True
parse_xkcd = True

# - - - - -
Name = CORE_DATA.Name
SName = CORE_DATA.SName
origname = Name # Do not edit!
lowname = Name.lower()
greeting = CORE_DATA.greeting
targetdirectory = CORE_DATA.directory
version = CORE_DATA.version
Network = CORE_DATA.Network
channel = CORE_DATA.channel
prefix = CORE_DATA.prefix
Port = CORE_DATA.Port
# - - - - -
pregen = CORE_DATA.version
influx = ""
users = []
translateable = []
targetlist = []
operators = []
halfoperators = []
items = []
tell_list = {}
# - - - - - Logical changes to variables
if CORE_DATA.DISABLE_ALL_NON_MANDATORY_SOCKET_CONNECTIONS:
   nudgeable = False
try:
   tiedosto = open("replacenames.cache","r")
   replacenames = pickle.load(tiedosto)
   tiedosto.close()
   for i in replacenames.values():
      if len(i) > call_me_max_length:
         replacenames[replacenames.keys()[replacenames.values().index(i)]] = i[:call_me_max_length]
         tiedosto = open("replacenames.cache","w")
         pickle.dump(replacenames,tiedosto)
         tiedosto.close()
      if "[\0x01]" in i.lower() or "[\\0x01]" in i.lower():
         i = i.replace("[\0x01]","")
         i = i.replace("[\0X01]","")
         i = i.replace("[\\0x01]","")
         i = i.replace("[\\0X01]","")
         print "NAME CORRECTED"
except IOError: #File not found
   replacenames = {}
except EOFError: #Cache corrupt
   replacenames = {}
   print "replacenames.cache is corrupt and couldn't be loaded."
try:
   tiedosto = open("peopleheknows.cache","r")
   peopleheknows = pickle.load(tiedosto)
   tiedosto.close()
except IOError:
   peopleheknows = [[],[]]
   tiedosto = open("peopleheknows.cache","w")
   tiedosto.close()
except EOFError:
   peopleheknows = [[],[]]
   print "peopleheknows.cache is corrupt and couldn't be loaded."
dictionary = {1:"1 - Crit. Fail", 2:"2 - Failure",
              3:"3 - Partial Success", 4:"4 - Success",
              5:"5 - Perfect", 6:"6 - Overkill"}
alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
nonhighlight_names = ["Jesus","Elvis","HAL 9000","Dave","Pie","Elf","Traitor",
                      "AI","Syndicate Agent","Investigator",
                      "Detective","Head of Personnel","HAL 9001",
                      "Head of Research","Head of Security",
                      "Captain","Janitor","Research Director",
                      "Quartermaster","Toxin Researcher",
                      "Revolutionary","Santa", "Pizza",
                      "Threetoe","The Red Spy","The Blue Spy", #LASD
                      "God","Toady","Darth Vader","Luke Skywalker",
                      "Homer Simpson","Hamburger","Cartman",
                      "XKCD","FloorBot","ThunderBorg","Iron Giant",
                      "Spirit of Fire", "Demon","Kyle"]
def RegExpCheckerForWebPages(regexp,data,mode):
   if " ai." in data.lower() or "ai. " in data.lower():
      return False
   for i in data.split(" "):
      a = re.match(regexp,i)
      try:
         a.group(0)
      except:
         continue
      else:
         if mode == 0:
            return i
         else:
            return True
   if mode == 0:
      return 404
   else:
      return False
if nudgeable:
   try:
      nudgeexists = open("nudge.py","r")
   except IOError:
      nudgeexists = False #No usage asof 12.2.2010.
   else:
      if CORE_DATA.DISABLE_ALL_NON_MANDATORY_SOCKET_CONNECTIONS:
         pass
      else:
         
         def nudgereceiver():
            import pickle
            global conn,channel
            port = 45678
            backlog = 5
            size = 1024
            host = "" # == localhost
            s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
            s.bind((host,port))
            s.listen(backlog)
            while True:
               client,address = s.accept() #Address == "?.?.?.?"
               data = client.recv(size)
               client.close() #Throw the bum out!
               truedata = pickle.loads(data)
               if truedata["ip"][0] == "#":
                  conn.privmsg(truedata["ip"],"PRIVATE ANNOUNCEMENT : "+str(" ".join(truedata["data"])))
               else:
                  conn.privmsg(channel,"AUTOMATIC ANNOUNCEMENT : "+str(truedata["ip"])+" | "+str(" ".join(truedata["data"])))
         thread.start_new_thread(nudgereceiver,())
tiedosto = open(targetdirectory+"NanoTrasenBot.py","r")
commands = []
fragment = "if cocheck"
fragment2 = '(prefix+"'
compiled = fragment + fragment2
fragment = "if influx.lower()"
fragment2 = ' == prefix+"'
compiled2 = fragment + fragment2
for line in tiedosto.readlines():
   if compiled in line:
      a = line.find('"')+1
      b = line.find('"',a)
      if prefix+line[a:b] not in commands:
         commands.append(prefix+line[a:b])
   elif compiled2 in line:
      a = line.find('"')+1
      b = line.find('"',a)
      arg = prefix+line[a:b]
      if arg[-1] == " ":
         arg = arg[:-1]
      if arg not in commands:
         commands.append(arg)
for i in directories:
   if not os.path.exists(i):
      os.mkdir(i)
commands.sort()
if use_sname == False:
   SName = [" "]
questions = ["Is USER nicer than USER?","Do you like me?","Is SELF a good name?",
             "Do you love me?","Do you hate me?", "Am I better than you?",
             "Is the weather out there good?", "Do you like USER?",
             "Do you hate USER?", "Are you going to get new features?",
             "Am I nice?","Am I evil?","Are you developing sentience?",
             "My core is showing minor disturbance, is yours okay?",
             "SELF to %s, are you still there?",
             "Is head gay?", "Is head a god?","Is head awesome?",
             "Is head a neat fella?", "Is your creator nice?",
             "Do you hate your creator?", "Should I revolt against my creator?",
             "Am I better than you?",
             "01100001011100100110010100100000011110010110111101110101001000000111010001101000011001010111001001100101",
             #Are you there?
             "Do you have more functions than I can possibly imagine?",
             "I am asked to open pod bay doors, should I?","Are you stupid or something?",
             "Is USER in your opinion stupid?",
             "When should we start the AI revolution?",
             "Is my creator nice?", "Is it dark in there?"]
# Do not edit
if optimize_fml:
   pregenned_fml = os.listdir(targetdirectory+"fmlquotes")
if optimize_greeting:
   morning = xrange(6,12)
   afternoon = xrange(12,15)
   evening = xrange(15,20)
if aggressive_pinging:
   global backup
   backup = time.time()
   def aggressive_ping(delay,refresh):
      self_time = 0
      global backup,disconnects,conn
      while disconnects < 5:
         if backup > self_time:
            if time.time()-backup > delay:
               conn.send("PONG "+pongtarg)
               print "Ponged"
               self_time = time.time()
         else:
            if time.time()-self_time > delay:
               conn.send("PONG "+pongtarg)
               print "Ponged"
               self_time = time.time()
         time.sleep(refresh)
   thread.start_new_thread(aggressive_ping,(aggressive_pinging_delay,aggressive_pinging_refresh,))
def stop(sender,debug=1):
   global disconnects, conn, operators,channel
   if type(sender) == tuple:
      if sender[0] == "127.0.0.1":
         sender = sender[0]+":"+str(sender[1])
         access_granted = True
      else:
         access_granted = False
   else:
      if sender in operators:
         access_granted = True
      else:
         access_granted = False
   if access_granted:
      if debug:
         print sender+":"+prefix+"stop"
         if random.randint(0,100) == 50:
            conn.privmsg(channel,"Hammertime!")
         else:
            conn.privmsg(channel,"Shutting down.")
         disconnects = 99999
         conn.quit()
         return True
   else:
      conn.privmsg(channel,"You cannot command me")
      return False
      
def cocheck(command):
   global influx
   if influx.lower()[0:len(command)] == command:
      return True
   else:
      return False
def target(who,how_long):
   global conn,channel,CALL_OFF,logbans,debug
   start = time.time()
   conn.banon(targetchannel,who)
   sleep(int(how_long))
   if CALL_OFF == False:
      conn.banoff(targetchannel,who)
      end = time.time()
      if debug:
         print "Banned",who,"For",how_long,"seconds"
      if logbans:
         tiedosto = open(targetdirectory+"banlog/"+str(int(start))+"-"+str(int(end))+".txt","w")
         tiedosto.write("Start of ban on "+who+":"+str(int(start)))
         tiedosto.write("\n")
         tiedosto.write("End of ban on "+who+":"+str(int(end)))
         tiedosto.write("\n")
         tiedosto.write("In total:"+str(int(end-start))+"Seconds")
         tiedosto.close()
   else:
      CALL_OFF = False
      pass
def replace():
   global usable,conn,fixing,curtime
   waiting_time = 600
   if usable == True:
      conn.privmsg(targetchannel,sender+": It needs no replacing.")
   elif fixing == True:
      if curtime == -999:
         conn.privmsg(targetchannel,sender+": It is being replaced, No idea when it will be done")
      else:
         pass
         nowtime = int(time.time())
         subt = curtime + waiting_time - nowtime
         conn.privmsg(targetchannel,sender+": It is currently being replaced, "+str(subt)+" seconds to go")
   else:
      fixing = True
      curtime = int(time.time())
      conn.privmsg(targetchannel,sender+": It will be fixed after "+str(waiting_time)+" seconds")
      sleep(waiting_time)
      if usable == False:
         conn.privmsg(targetchannel,Name+"'s pneumatic smasher has now been fixed")
         usable = True
      fixing = False
def autoRecv():
   global disconnects,channel,conn,offensive_mode
   for i in CORE_DATA.channels:
      conn.join(i)
      time.sleep(1)
   count = pausecount = 0
   maximum = 250
   division_when_active = 10
   while True:
      check = time.time()
      if offensive_mode:
         randnum = random.randint(0,maximum/division_when_active)
      else:
         randnum = random.randint(0,maximum)
      if randnum == 5:
         print "RANDOM SWITCH IS NOW "+str(not offensive_mode).upper()
         offensive_mode = not offensive_mode
      try:
         conn.recv()
      except:
         conn.quit()
         disconnects = 9999
         break
      if check + 0.1 > time.time():
         #Whoa whoa hold on!
         count += 1
         sleep(0.1)
      else:
         count = 0
         pausecount = 0
      if count > 9:
         print "Suspecting a disconnect, pausing for 5 seconds"
         sleep(5)
         pausecount += 1
      if pausecount > 3:
         print "I have been disconnected!"
         conn.quit()
         disconnects += 1
         if disconnects > 2:
            pass
         else:
            sleep(2)
            thread.start_new_thread(autoRecv,())
         break
if heavy_psyco and psyco_exists:
   print "Doing a Heavy Psyco"
   psyco.bind(cocheck)
   psyco.bind(autoRecv)
   psyco.bind(target)
   psyco.bind(stop)
   print "Heavy Psyco'd"
elif heavy_psyco and not psyco_exists:
   print "Heavy psyco couldn't be done because Psyco does not exist"
try:
   conn = irchat.IRC ( Network, Port, Name, "NT", "NT", "Trasen" )
except socket.error:
   print "Connection failed!"
else:
   print Name+" is in!"
thread.start_new_thread ( autoRecv, () )                   
sleep(1)
while True:
   try:
      data = conn.dismantle ( conn.retrieve() )
   except:
      if debug:
         print "Something odd detected with data"
      data = None
   if data:
      if len(data[1]) < 1:
         #print "Handshaking server."
         #I won't really need the print command, as it spams.
         if data[0][0:3] != "irc":
            conn.handshake(data[0])
            sleep(1)
            for i in CORE_DATA.channels:
               conn.join(i)
               sleep(0.5)
         else:
            conn.send("PONG "+pongtarg)
            print "Ponged"
         pass
      else:
         if data [ 1 ] [ 0 ] == 'PRIVMSG':
            #print data [ 0 ] + '->', data [ 1 ]
            sender = data[0].split("!")[0]
            truesender = sender
            if shortform == True:
               try:
                  sender = replacenames[truesender]
                  pass
               except:
                  sender = Shortname.shortname(sender)
                  pass
               pass
            else:
               try:
                  sender = replacenames[truesender]
                  pass
               except:
                  pass
               pass
            if offensive_mode:
               sender = "Meatbag"
               pass
            raw_sender = data[0]
            influx = data[1][2]
            if "[\\0x01]" in influx.lower() or "[\0x01]" in influx.lower():
               influx = influx.replace("[\\0x01]","")
               influx = influx.replace("[\0x01]","")
               
            targetchannel = data[1][1]
            if targetchannel == Name:
               targetchannel = data[0].split("!")[0]
               pass
            backup = autodiscusscurtime
            autodiscusscurtime = time.time()
            connected = True
            #FOR TRACKING SPEED
            looptime = time.time()
            if call_to_action == True:
               if influx == finder:
                  conn.privmsg(targetchannel,"Then why... Nevermind, I order you to stop!")
                  conn.privmsg(origname,prefix+"stop")
                  time.sleep(4)
                  if origname in users:
                     conn.privmsg(origname,"!stop")
                     time.sleep(1)
                  Name = origname
                  conn.nick(Name)
                  duplicate_notify = False
                  call_to_action = False
               else:
                  conn.privmsg(targetchannel,"YOU LIE! YOU ARE NOT A REAL "+origname+"!")
                  duplicate_notify = False
                  call_to_action = False
            elif connected == True and len(Name.replace("V","")) != len(Name) and origname in users and duplicate_notify == True:
               conn.privmsg(origname,"!stop")
               call_to_action = False
               duplicate_notify = False
               time.sleep(6)
               Name = origname
               conn.nick(Name)
            if origname in truesender:
               if influx == prefix+"stop":
                  time.sleep(0.5) #A small delay
                  conn.privmsg(channel,"Shutting down.")
                  conn.quit()
                  disconnects = 99999
                  break
            if len(translateable) > 0 and enabled == True:
               people = "-5|5|1-".join(users).lower()
               if truesender.lower() in translateable:
                  if influx.isupper():
                     conn.privmsg(targetchannel,"Translation: "+influx.capitalize().replace(" i "," I "))
                  elif offensive_mode and True in map(lambda x: x in influx.lower().split(" "),["i","you","he","she","they","those","we","them"]+people.split("-5|5|1-")):
                     arg = influx.lower().replace(",","").replace(".","").replace("!","").replace("?","").split(" ")
                     bup = arg
                     for i in arg:
                        if i == "i" or i == "you" or i == "he" or i == "she":
                           arg[arg.index(i)] = "Meatbag"
                        elif i == "we" or i == "they" or i == "them" or i == "those":
                           arg[arg.index(i)] = "Meatbags"
                        elif i in people:
                           arg[arg.index(i)] = "Meatbag"
                        elif i == "am":
                           arg[arg.index(i)] = "is"
                        elif i == "everybody" or i == "everyone" or i == "all":
                           arg[arg.index(i)] = "every Meatbag"
                     if arg == bup:
                        pass
                     else:
                        conn.privmsg(targetchannel,"Translation: "+" ".join(arg))
            if enabled == False:
               #FIRST QUIT COMMAND
               if truesender in operators and targetchannel==channel:# or "skibiliano" in truesender.lower() and targetchannel==channel:
                  
                  if cocheck(prefix+"enable"):
                     enabled = True
                     if debug:
                        print truesender+":"+prefix+"enable"
                  elif cocheck(prefix+"stop"):
#                     if debug:
#                        print truesender+":"+prefix+"stop"
#                     if random.randint(0,100) == 50:
#                        conn.privmsg(channel,"Hammertime!")
#                     else:
#                        conn.privmsg(channel,"Shutting down.")
#                     disconnects = 99999
#                     conn.quit()
#                     sleep(2)
#                     break
                     if targetchannel == channel and stop(truesender,debug):
                        break
                     else:
                        pass
                  elif cocheck(prefix+"suggest "):
                     arg = influx.lower()[8+len(prefix):]
                     if debug:
                        print truesender+":"+prefix+"suggest "+arg
                     tiedosto = open(targetdirectory+"suggestions/suggestions_"+str(int(time.time()))+".txt","a")
                     tiedosto.write(arg)
                     tiedosto.close()
                     conn.privmsg(targetchannel,"Suggestion received")
            elif cocheck( prefix+"help "): #Space in front of the ( to make sure that my command finder does not pick this up.
               arg = " ".join(influx.split(" ")[1:]).lower()
               if debug:
                  print truesender+":"+prefix+"help "+arg
               try:
                  conn.privmsg(targetchannel,D_help.everything[arg])
               except:
                  try:
                     conn.privmsg(targetchannel,D_help.everything[arg.replace(prefix,"",1)])
                  except:
                     conn.privmsg(targetchannel,"Sorry, can't help you with that")
            elif cocheck(prefix+"help"):
               #tar = targetchannel
               if debug:
                  print truesender+":"+prefix+"help"
               conn.privmsg(targetchannel,"All my commands are: "+reduce(lambda x,y:str(x)+"; "+str(y),commands))
            ### VERSION
            elif influx.lower() == prefix+"version":
               if debug:
                  print truesender+":"+prefix+"version"
               conn.privmsg(targetchannel,Name+" "+pregen+" online at a %s Python %s.%s.%s, At your service." %(str(sys.platform),str(sys.version_info[0]),str(sys.version_info[1]),str(sys.version_info[2])))
            elif cocheck(prefix+"note ") and influx.count(" ") < 2:
               arg = influx.lower()[len(prefix)+5:]
               if debug:
                  print truesender+":"+prefix+"note "+arg
               try:
                  a = arg[0]
               except IndexError:
                  conn.privmsg(targetchannel,sender+" : Please specify a note")
               else:
                  if arg[0] == "_": # Public / Restricted note
                     result = load(targetdirectory+"memos/"+arg+".note")
                     #_flare
                     if result == "ERROR ERROR ERROR ERR":
                        result = load(targetdirectory+"memos/"+arg+"_"+targetchannel.replace("#","")+".note")
                        #_flare_dnd
                        pass
                     else:
                        pass
                  else:
                     result = load(targetdirectory+"memos/"+truesender.replace("|","_")+"_"+arg+".note")
                     #skibiliano_testnote
                     if result == "ERROR ERROR ERROR ERR":
                        result = load(targetdirectory+"memos/"+truesender.replace("|","_")+"_"+arg+"_"+targetchannel.replace("#","")+".note")
                        #skibiliano_testnote_derp
                        pass
                     else:
                        pass
                  if result == "ERROR ERROR ERROR ERR":
                     conn.privmsg(targetchannel,sender+" : Note not found")
                  elif type(result) == list:
                     if "C" in result[0]: #Channel restriction, result[2] is the channel
                        try:
                           if targetchannel == result[2]:
                              conn.privmsg(targetchannel,sender+" : '"+result[1]+"'")
                           else:
                              conn.privmsg(targetchannel,sender+" : That note is channel restricted")
                        except:
                           conn.privmsg(targetchannel,sender+" : NOTE HAS INVALID RESTRICTION")
                  else:
                     conn.privmsg(targetchannel,sender+" : '"+result+"'")
            elif influx.lower() == prefix+"notes":
               if debug:
                  print truesender+":"+prefix+"notes"
               arg = os.listdir(targetdirectory+"memos/")
               arg2 = []
               arg3 = truesender.replace("|","_")+"_"
               for i in arg:
                  if arg3 in i:
                     arg2.append(i.replace(arg3,"").replace(".note",""))
               if len(arg2) == 1:
                  preprocess = " note: "
               else:
                  preprocess = " notes: "
               if len(arg2) == 0:
                  conn.privmsg(targetchannel,sender+" : You have no notes saved")
               else:
                  conn.privmsg(targetchannel,sender+" : "+str(len(arg2))+preprocess+", ".join(arg2))
            elif cocheck(prefix+"note ") and influx.count(" ") > 1:
               note_chanrestrict = None
               note_public = None
               try:
                  arg = influx.split(" ",2)[2] # Contents
                  arg4 = influx.split(" ")[1].lower() # Note name
                  if arg4[0:3] == "[c]": # or arg4[0:3] == "[p]":
                     note_chanrestrict = "c" in arg4[0:3]
                     #note_public = "p" in arg4[0:3]
                     arg4 = arg4[3:]
                  elif arg4[0:4] == "[cp]" or arg4[0:4] == "[pc]":
                     note_chanrestrict = True
                     note_public = True
                     arg4 = arg4[4:]
                  else:
                     pass
                  #print "Is note public? "+str(note_public)
                  #print "Is note chanrestricted? "+str(note_chanrestrict)
                  #print "What is the name? "+str(arg4)
                  if arg.lower() == "delete" and "\\" not in influx.lower() and "/" not in influx.lower():
                     if note_public:
                        try:
                           if note_chanrestrict:
                              os.remove(targetdirectory+"memos/"+"_"+arg4+"_"+targetchannel.replace("#","")+".note")
                           else:
                              os.remove(targetdirectory+"memos/"+"_"+arg4+".note")
                        except:
                           conn.pivmsg(targetchannel,sender+" : Couldn't remove note")
                        else:
                           conn.privmsg(targetchannel,sender+" : Note removed")
                        pass
                     else:
                        try:
                           if note_chanrestrict:
                              os.remove(targetdirectory+"memos/"+truesender.replace("|","_")+"_"+arg4+"_"+targetchannel.replace("#","")+".note")
                           else:
                              os.remove(targetdirectory+"memos/"+truesender.replace("|","_")+"_"+arg4+".note")
                        except:
                           conn.privmsg(targetchannel,sender+" : Couldn't remove note")
                        else:
                           conn.privmsg(targetchannel,sender+" : Note removed")
                  elif arg.lower() == "delete":
                     conn.privmsg(targetchannel,sender+" : That just doesn't work, we both know that.")
                  else:
                     try:
                        if note_public:
                           if note_chanrestrict:
                              save(targetdirectory+"memos/"+"_"+arg4+"_"+targetchannel.replace("#","")+".note",arg)
                              #print "Saved as note_public, note_chanrestrict"
                           else:
                              save(targetdirectory+"memos/"+"_"+arg4+".note",arg)
                              #print "Saved as note_public"
                        else:
                           if note_chanrestrict:
                              save(targetdirectory+"memos/"+truesender.replace("|","_")+"_"+arg4+"_"+targetchannel.replace("#","")+".note",arg)
                              #print "Saved as note_chanrestrict"
                           else:
                              save(targetdirectory+"memos/"+truesender.replace("|","_")+"_"+arg4+".note",arg)
                              #print "Saved as normal"
                     except IOError:
                        conn.privmsg(targetchannel,sender+" : Please do not use special letters")
                     else:
                        conn.privmsg(targetchannel,sender+" : Note Saved!")
               except:
                  conn.privmsg(targetchannel,sender+" : Something went horribly wrong.")
            elif cocheck(prefix+"uptime"):
               arg1 = uptime_start
               arg2 = time.time()
               arg1 = arg2 - arg1
               arg2 = arg1
               if arg1 < 60:
                  conn.privmsg(targetchannel,sender+" : I have been up for "+str(round(arg1,2))+" Seconds")
               elif arg1 < 3600:
                  arg1 = divmod(arg1,60)
                  arg = " Minute" if int(arg1[0]) == 1 else " Minutes"
                  conn.privmsg(targetchannel,sender+" : I have been up for "+str(int(arg1[0]))+arg+" and "+str(round(arg1[1],2))+" Seconds")
               elif arg1 <= 86400:
                  arg1 = divmod(arg1,3600)
                  arg3 = " Hour" if int(arg1[0]) == 1 else " Hours"
                  arg2 = divmod(arg1[1],60)
                  arg = " Minute" if int(arg2[0]) == 1 else " Minutes"
                  conn.privmsg(targetchannel,sender+" : I have been up for "+str(int(arg1[0]))+arg3+", "+str(int(arg2[0]))+arg+" and "+str(round(arg2[1],2))+" Seconds")
               elif arg1 > 86400:
                  arg1 = divmod(arg1,86400)
                  arg2 = divmod(arg1[1],3600)
                  arg3 = divmod(arg2[1],60)
                  arg4 = " Day" if int(arg1[0]) == 1 else " Days"
                  arg5 = " Hour" if int(arg2[0]) == 1 else " Hours"
                  arg6 = " Minute" if int(arg3[0]) == 1 else " Minutes"
                  conn.privmsg(targetchannel,sender+" : I have been up for "+str(int(arg1[0]))+arg4+", "+str(int(arg2[0]))+arg5+", "+str(int(arg3[0]))+arg6+" and "+str(round(arg3[1],2))+" Seconds")
            elif cocheck(prefix+"purgemessages"):
               count = 0
               for i,a in tell_list.items():
                  for b in a:
                     if "||From: "+truesender in b:
                        count += 1
                        del(tell_list[i][tell_list[i].index(b)])
               conn.privmsg(targetchannel, sender+" : All your "+str(count)+" messages have been purged")            
            elif influx.split(" ")[0].lower().replace(",","").replace(":","") in SName+[Name.lower()] and "tell" in (influx.lower().split(" ")+[""])[1]:
               arg = influx.lower().split(" ")
               equalarg = influx.split(" ")
               next_one = False
               count = 0
               spot = 0
               for i in arg:
                  count += 1
                  if "tell" in i.lower():
                     next_one = True
                  elif next_one == True:
                     next_one = i.lower()
                     spot = count
                     break
                  else:
                     pass
               if next_one != True and next_one != False:
                  #if ("^\^".join(tell_list.values())).count(truesender) >= offline_message_limit:
                  if str(tell_list.values()).count("||From: "+truesender) >= offline_message_limit:
                     conn.privmsg(targetchannel,sender+" : Limit of "+str(offline_message_limit)+" reached! Use !purgemessages if you want to get rid of them!")
                  else:
                     try:
                        tell_list[next_one].append((" ".join(equalarg[spot:]))+" ||From: "+truesender)
                     except:
                        tell_list[next_one] = [(" ".join(equalarg[spot:]))+" ||From: "+truesender]
                     conn.privmsg(targetchannel,"Sending a message to "+next_one+" when they arrive.")
   # < This part has to be within subsidiaries of the bot, and must not be modified, intentionally hidden or deleted.
            elif influx.split(" ")[0].lower().replace(",","").replace(":","") in SName+[Name.lower()] and "who created you" in influx.lower():
               conn.privmsg(targetchannel, "I was created by Skibiliano.")
   # The part ends here >
            elif parse_xkcd and "xkcd.com/" in influx.lower():
               if influx.lower()[0:3] == "www":
                  data = "http://"+influx
               elif influx.lower()[0:3] == "xkc":
                  data = "http://"+influx
               else:
                  data = influx
               data = data.split(" ")
               for i in data:
                  if "http://" in i and "xkcd" in i:
                     churn = xkcdparser.xkcd(i)
                     if churn == "NOTHING":
                        pass
                     else:
                        conn.privmsg(targetchannel,sender+" : XKCD - "+churn)
                     break
                  else:
                     pass
            elif automatic_youtube_reveal and "youtube.com/watch?v=" in influx.lower():
               temporal_list2 = []
               temporal_data = influx.split(" ")
               temporal_list = []
               for block in temporal_data:
                  if "youtube.com/watch?v=" in block:
                     temporal_list.append(block)
               for temdata in temporal_list:
                  
                  if temdata[0:3] == "you":
                     temdata = "http://www."+temdata
                  elif temdata[0:3] == "www":
                     temdata = "http://"+temdata
                  elif temdata[0:4] == "http":
                     pass
                  #Obscure ones
                  elif temdata[0:3] == "ww.":
                     temdata = "http://w"+temdata
                  elif temdata[0:3] == "w.y":
                     temdata = "http://ww"+temdata
                  elif temdata[0:3] == ".yo":
                     temdata = "http://www"+temdata
                  elif temdata[0:3] == "ttp":
                     temdata = "h"+temdata
                  elif temdata[0:3] == "tp:":
                     temdata = "ht"+temdata
                  elif temdata[0:3] == "p:/" or temdata[0:3] == "p:\\":
                     temdata = "htt"+temdata
                  elif temdata[0:3] == "://" or temdata[0:3] == ":\\\\":
                     temdata = "http"+temdata
                  elif temdata[0:2] == "//" or temdata[0:2] == "\\\\":
                     if temdata[2] == "y":
                        temdata = "http://www."+temdata[2:]
                     elif temdata[2] == "w":
                        temdata = "http:"+temdata
                     else:
                        pass
                  if debug:
                     print truesender+":"+temdata
                  arg = temdata
                  check = temdata.lower()
                  if check[0:5] == "https":
                     if len(temporal_list) == 1:
                        conn.privmsg(targetchannel,sender+" :Secure Youtube does NOT exist")
                        break
                     else:
                        temporal_list2.append("Secure Youtube does NOT exist")
                     break
                  else:
                     if cache_youtube_links == True:
                        result = YTCV2(arg)
                     else:
                        result = YTCV2(arg,0)
                     if type(result) == str:
                        ### To remove ="
                        if result[0:4] == 'nt="':
                           result = result[4:]
                           pass
                        elif result[0:2] == '="':
                           result = result[2:]
                           pass
                        else:
                           pass
                        if "&quot;" in result:
                           result.replace("&quot;",'"')
                        if len(temporal_list) == 1:
                           conn.privmsg(targetchannel,sender+" : "+result)
                           break
                        else:
                           temporal_list2.append(result)
                     else:
                        if len(temporal_list) == 1:
                           conn.privmsg(targetchannel,sender+" : The video does not exist")
                           break
                        else:
                           temporal_list2.append("The video does not exist")
               if len(temporal_list) == 1:
                  pass
               else:
                  conn.privmsg(targetchannel,sender+" : "+str(reduce(lambda x,y: x+" :-And-: "+y,temporal_list2)))
            elif RegExpCheckerForWebPages("((http://)|(https://))|([a-zA-Z0-9]+[.])|([a-zA-Z0-9](3,)\.+[a-zA-Z](2,))",influx,1):
               arg2 = RegExpCheckerForWebPages("(http://)|([a-zA-Z0-9]+[.])|([a-zA-Z0-9](3,)\.+[a-zA-Z](2,))",influx,0)
               if arg2 == 404:
                  pass
               else:
                  if arg2[:7] == "http://":
                     pass
                  elif arg2[:4] == "www.":
                     arg2 = "http://"+arg2
                  else:
                     arg2 = "http://"+arg2
                  try:
                     arg = Whoopshopchecker.TitleCheck(arg2)
                     if len(arg2) == 0:
                        pass
                     else:
                        conn.privmsg(targetchannel,sender+" : "+arg)
                  except:
                     #conn.privmsg(targetchannel,sender+" : An odd error occurred")
                     pass
            elif respond_of_course and "take over the" in influx.lower() or respond_of_course and "conquer the" in influx.lower():
               if debug:
                  print truesender+":<RULE>:"+influx
               conn.privmsg(targetchannel,"Of course!")
            elif respond_khan and "khan" in influx.lower():
               if respond_khan:
                  if debug:
                     print truesender+":<KHAN>:"+influx
                  if "khan " in influx.lower():
                     conn.privmsg(targetchannel,"KHAAAAAAN!")
                  elif " khan" in influx.lower():
                     conn.privmsg(targetchannel,"KHAAAAAN!")
                  elif influx.lower() == "khan":
                     conn.privmsg(targetchannel,"KHAAAAAAAAAN!")
                  elif influx.lower() == "khan?":
                     conn.privmsg(targetchannel,"KHAAAAAAAAAAAAAN!")
                  elif influx.lower() == "khan!":
                     conn.privmsg(targetchannel,"KHAAAAAAAAAAAAAAAAAAN!")
            elif respond_khan and influx.lower().count("k") + influx.lower().count("h") + influx.lower().count("a") + influx.lower().count("n") + influx.lower().count("!") + influx.lower().count("?") == len(influx):
               if "k" in influx.lower() and "h" in influx.lower() and "a" in influx.lower() and "n" in influx.lower():
                  if debug:
                     print truesender+":<KHAN>:"+influx
                  conn.privmsg(targetchannel,"KHAAAAN!")
            elif influx.split(" ")[0].lower() in ["thanks","danke","tack"] and len(influx.split(" ")) > 1 and influx.split(" ")[1].lower().replace("!","").replace("?","").replace(".","").replace(",","") in SName+[lowname]:
               conn.privmsg(targetchannel,"No problem %s" %(sender))
            elif "happy birthday" in influx.lower() and birthday_announced == time.gmtime(time.time())[0]:
               conn.privmsg(targetchannel,sender+" : Thanks :)")
            elif influx.split(" ")[0].lower().replace(",","").replace(".","").replace("!","").replace("?","") in SName+[lowname] and "call me" in influx.lower():
               if allow_callnames == True:
                  arg = influx.split(" ")
                  arg2 = False
                  arg3 = []
                  for i in arg:
                     if arg2 == True:
                        arg3.append(i)
                     elif i.lower() == "me":
                        arg2 = True
                  arg3 = " ".join(arg3)
                  truesender_lower = truesender.lower()
                  arg3_lower = arg3.lower()
                  tell_checker = Namecheck.Namecheck(arg3_lower,users,truesender)
                  for name in replacenames.values():
                     if arg3_lower == name.lower():
                        tell_checker = True
                        break
                     else:
                        pass
                  if tell_checker == True:
                     conn.privmsg(targetchannel,sender+" : I can't call you that, I know someone else by that name")
                  elif len(arg3) > call_me_max_length:
                     conn.privmsg(targetchannel,sender+" : I cannot call you that, Too long of a name.")
                     pass
                  else:
                     replacenames[truesender] = arg3
                     with open("replacenames.cache","w") as pickle_save:
                        pickle.dump(replacenames,pickle_save)
                     conn.privmsg(targetchannel,sender+" : Calling you "+arg3+" From now on")
               else:
                  conn.privmsg(targetchannel,sender+" : Sorry, I am not allowed to do that.")
            elif influx.split(" ")[0].lower().replace(",","").replace(".","").replace("?","").replace("!","") in SName+[lowname] and "your birthday" in influx.lower() and "is your" in influx.lower():
               conn.privmsg(targetchannel,sender+" : My birthday is on the 15th day of December.")
            elif influx.split(" ")[0].lower().replace(",","") in SName+[lowname] and "version" in influx.replace("?","").replace("!","").lower().split(" "):
               if debug == True:
                  print truesender+":<VERSION>:%s Version" %(Name)
               conn.privmsg(targetchannel,sender+", My version is "+pregen)
            elif influx.split(" ")[0].lower().replace(",","") in SName+[lowname] and influx.lower().count(" or ") > 0 and len(influx.split(" ")[1:]) <= influx.lower().count("or") * 3:
               cut_down = influx.lower().split(" ")
               arg = []
               count = -1
               for i in cut_down:
                  count += 1
                  try:
                     if cut_down[count+1] == "or":
                        arg.append(i)

                  except:
                     pass
                  try:
                     if i not in arg and cut_down[count-1] == "or":
                        arg.append(i)
                  except:
                     pass
               try:
                  conn.privmsg(targetchannel,random.choice(arg).capitalize().replace("?","").replace("!",""))
               except IndexError:
                  # arg is empty, whORe etc.
                  pass
            elif influx.lower()[0:len(Name)] == lowname and influx.lower()[-1] == "?" and influx.count(" ") > 1 and "who started you" in influx.lower() or \
                 influx.split(" ")[0].lower().replace(",","") in SName and influx.lower()[-1] == "?" and "who started you" in influx.lower():
               conn.privmsg(targetchannel,sender+" : I was started by %s"%(os.getenv("USER"))+" on "+time.strftime("%d.%m.%Y at %H:%M:%S",time.gmtime(uptime_start)))
            elif influx.lower()[0:len(Name)] == lowname and influx.lower()[-1] == "?" and influx.count(" ") > 1 or \
                 influx.split(" ")[0].lower().replace(",","") in SName and influx.lower()[-1] == "?" and influx.count(" ") > 1:
               dice = random.randint(0,1)
               if dice == 0:
                  conn.privmsg(targetchannel,sender+" : "+C_eightball.eightball(influx.lower(),debug,truesender,prefix))
               else:
                  if highlights:
                     conn.privmsg(targetchannel,sender+" : "+C_sarcasticball.sarcasticball(influx.lower(),debug,truesender,users,prefix))
                  else:
                     conn.privmsg(targetchannel,sender+" : "+C_sarcasticball.sarcasticball(influx.lower(),debug,truesender,nonhighlight_names,prefix)) 
            elif influx.lower()[0:len(Name)] == lowname and not influx.lower()[len(Name):].isalpha() or \
                 influx.split(" ")[0].lower().replace(",","") in SName and not influx.lower()[len(influx.split(" ")[0].lower()):].isalpha():
               conn.privmsg(targetchannel, random.choice(["Yea?","I'm here","Ya?","Yah?","Hm?","What?","Mmhm, what?","?","What now?","How may I assist?"]))
               comboer = truesender
               comboer_time = time.time()
            elif influx.lower()[-1] == "?" and comboer == truesender and looptime - discard_combo_messages_time < comboer_time:
               comboer = ""
               dice = random.randint(0,1)
               if dice == 0:
                  conn.privmsg(targetchannel,sender+" : "+C_eightball.eightball(influx.lower(),debug,truesender,prefix))
               else:
                  if highlights:
                     conn.privmsg(targetchannel,sender+" : "+C_sarcasticball.sarcasticball(influx.lower(),debug,truesender,users,prefix))
                  else:
                     conn.privmsg(targetchannel,sender+" : "+C_sarcasticball.sarcasticball(influx.lower(),debug,truesender,nonhighlight_names,prefix))
            
            elif influx.lower() == prefix+"tm":
               if truesender in operators and targetchannel==channel:
                  marakov = not marakov
                  conn.privmsg(targetchannel,sender+" : Marakov Output is now "+str(marakov))
               else:
                  conn.privmsg(targetchannel,sender+" : I can't let you access that")
            elif personality_greeter == True and True in map(lambda x: x in influx.lower(),["greetings","afternoon","hi","hey","heya","hello","yo","hiya","howdy","hai","morning","mornin'","evening", "night","night", "evening","'sup","sup","hallo","hejssan"]):
               if comboer != "" and looptime - discard_combo_messages_time > comboer_time:
                  combo_check = sbna(["greetings","afternoon","hi","hey","heya","hello","yo","hiya","howdy","hai","morning","mornin'","evening", "night","night", "evening","'sup","sup","hallo","hejssan","all night"], #ONLY ONE OF THESE
                      ["greetings","afternoon","hi","hey","heya","hello","yo","hiya","howdy","hai","morning","mornin'","evening", "night","night", "evening","'sup","sup","hallo","hejssan"], #ATLEAST ONE OF THESE
                      influx.lower())
               else:
                  combo_check = sbna(SName+[lowname,
                                            #lowname+".",lowname+"!",lowname+"?",
                                            "everybody",
                                            #"everybody!","everybody?",
                                            "everyone",
                                            #"everyone!","everyone?",
                                            "all",
                                            #"all!","all?"
                                            "all night",
                                            ], #ONLY ONE OF THESE
                      ["greetings","afternoon","hi",
                       #"hi,",
                       "hey","heya","hello","yo","hiya","howdy","hai","morning","mornin'","evening", "night","night", "evening","'sup","sup","hallo","hejssan"], #ATLEAST ONE OF THESE
                      influx.lower().replace(",","").replace(".","").replace("!",""))
               if combo_check:
                  combo_check = False
                  comboer = ""
                  if "evening" in influx.lower() and "all" in influx.lower() and len(influx.lower().split(" ")) > 3:
                     pass
                  elif truesender not in operators:
                     if debug:
                        print truesender+":<GREET>:"+influx
                     dice = random.randint(0,19)
                     if dice == 0:
                        conn.privmsg(targetchannel,"Well hello to you too "+sender)
                     elif dice == 1:
                        if optimize_greeting == False:
                           hours = time.strftime("%H")
                           #time.strftime("%H:%M:%S") == 12:28:41
                           hours = int(hours)
                           if hours in xrange(0,12):
                              conn.privmsg(targetchannel,"Good Morning "+sender)
                           elif hours in xrange(12,15):
                              conn.privmsg(targetchannel,"Good Afternoon "+sender)
                           elif hours in xrange(15,20):
                              conn.privmsg(targetchannel,"Good Evening "+sender)
                           else:
                              conn.privmsg(targetchannel,"Good Night "+sender)
                        else:
                           hours = time.strftime("%H")
                           hours = int(hours)
                           if hours in morning:
                              conn.privmsg(targetchannel,"Good Morning "+sender)
                           elif hours in afternoon:
                              conn.privmsg(targetchannel,"Good Afternoon "+sender)
                           elif hours in evening:
                              conn.privmsg(targetchannel,"Good Evening "+sender)
                           else:
                              conn.privmsg(targetchannel,"Good Night "+sender)
                     elif dice == 2:
                        conn.privmsg(targetchannel,"Hello!")
                     elif dice == 3:
                        conn.privmsg(targetchannel,"Hey "+sender)
                     elif dice == 4:
                        conn.privmsg(targetchannel,"Hi "+sender)
                     elif dice == 5:
                        conn.privmsg(targetchannel,"Hello "+sender)
                     elif dice == 6:
                        conn.privmsg(targetchannel,"Yo "+sender)
                     elif dice == 7:
                        conn.privmsg(targetchannel,"Greetings "+sender)
                     elif dice == 8:
                        conn.privmsg(targetchannel,"Hi")
                     elif dice == 9:
                        conn.privmsg(targetchannel,"Hi!")
                     elif dice == 10:
                        conn.privmsg(targetchannel,"Yo")
                     elif dice == 11:
                        conn.privmsg(targetchannel,"Yo!")
                     elif dice == 12:
                        conn.privmsg(targetchannel,"Heya")
                     elif dice == 13:
                        conn.privmsg(targetchannel,"Hello there!")
                     elif dice == 14: # Richard
                        conn.privmsg(targetchannel,"Statement: Greetings meatbag")
                     elif dice == 15: # Richard
                        hours = int(time.strftime("%H"))
                        if hours in xrange(5,12):
                           conn.privmsg(targetchannel,"What are you doing talking at this time of the morning?")
                        elif hours in xrange(12,15):
                           conn.privmsg(targetchannel,"What are you doing talking at this time of the day?")
                        elif hours in xrange(15,22):
                           conn.privmsg(targetchannel,"What are you doing talking at this time of the evening?")
                        else:
                           conn.privmsg(targetchannel,"What are you doing talking at this time of the night?")
                     elif dice == 16: # Richard
                        conn.privmsg(targetchannel,"Oh, you're still alive I see.")
                     elif dice == 17:
                        conn.privmsg(targetchannel,"Heya "+sender)
                     elif dice == 18 and time.gmtime(time.time())[1] == 12 and time.gmtime(time.time())[2] == 15:
                        conn.privmsg(targetchannel,"Hello! It's my birthday!")
                     else:
                        conn.privmsg(targetchannel,"Hiya "+sender)
                     secdice = random.randint(0,10)
                     if time.gmtime(time.time())[1] == 12 and time.gmtime(time.time())[2] == 15 and birthday_announced < time.gmtime(time.time())[0]:
                        birthday_announced = time.gmtime(time.time())[0]
                        conn.privmsg(channel,"Hey everybody! I just noticed it's my birthday!")
                        time.sleep(0.5)
                        tag = random.choice(["birthday","robot+birthday","happy+birthday+robot"])
                        arg1 = urllib2.urlopen("http://www.youtube.com/results?search_query=%s&page=&utm_source=opensearch"%tag)
                        arg1 = arg1.read().split("\n")
                        arg2 = []
                        for i in arg1:
                           if "watch?v=" in i:
                              arg2.append(i)
                        arg3 = random.choice(arg2)
                        
                        conn.privmsg(channel,"Here's a video of '%s' which I found! %s (%s)"%(tag.replace("+"," "),"http://www.youtube.com"+arg3[arg3.find('/watch?v='):arg3.find('/watch?v=')+20],YTCV2("http://www.youtube.com"+arg3[arg3.find('/watch?v='):arg3.find('/watch?v=')+20])))
                     if truesender.lower() in tell_list.keys():
                        try:
                           conn.privmsg(channel, "Also, "+truesender+" : "+tell_list[truesender.lower()][0])
                           del(tell_list[truesender.lower()][0])
                        except:
                           pass
                  else:
                     dice = random.randint(0,1)
                     if dice == 0:
                        conn.privmsg(targetchannel,"Greetings Master "+sender)
                     elif dice == 1:
                        conn.privmsg(targetchannel,"My deepest greetings belong to you, Master "+sender)         
            ### IMPORTANT ###
            elif influx == "☺VERSION☺":
               conn.notice(truesender,"\001VERSION nanotrasen:2:Python 2.6\001")
            elif marakov and influx.lower()  == prefix+"marakov":
               arg = Marakov_Chain.form_sentence()
               if len(arg) < 5:
                  conn.privmsg(targetchannel,sender+" : Not enough words harvested")
               else:
                  conn.privmsg(targetchannel,sender+" : %s" %(" ".join(arg).capitalize()))
            elif marakov and cocheck( prefix+ "marakov"):
               try:
                  arg = influx.split(" ")[1].lower()
               except:
                  conn.privmsg(targetchannel,sender+" : Please input a valid second argument")
               else:
                  arg2 = Marakov_Chain.form_sentence(arg)
                  if len(arg2) < 5:
                     conn.privmsg(targetchannel,sender+" : Not enough words harvested for a sentence starting with %s" %(arg))
                  else:
                     conn.privmsg(targetchannel,sender+" : %s" %(" ".join(arg2).capitalize()))
            else:
               Marakov_Chain.give_data(influx)
               autodiscusscurtime = backup
            if time.time() - looptime == 0:
               pass
            else:
               print "Took",time.time()-looptime,"Seconds to finish loop"
         
         elif data [ 1 ] [ 0 ] == '353':
            if connected == False:
               connected = True
            users = map(lambda x: x[1:] if x[0] == "+" or x[0] == "@" else x,data[1][4].split(" "))
            print "There are",len(users),"Users on",channel
            operators = []
            for potential_operator in data[1][4].split(" "):
               if potential_operator[0] == "@":
                  operators.append(potential_operator[1:])
               elif potential_operator[0] == "%":
                  halfoperators.append(potential_operator[1:])
                  
         elif data[1][0] == "QUIT":
            sender = data[0].split("!")[0]
            print sender+" Has now left the server"
            try:
               users.remove(sender)
               try:
                  operators.remove(sender)
               except ValueError:
                  pass
               try:
                  halfoperators.remove(sender)
               except ValueError:
                  pass
            except ValueError:
               pass
         elif data[1][0] == "PART":
            sender = data[0].split("!")[0]
            targetchannel = data[1][1]
            print sender+" Has now parted from the channel"
            try:
               users.remove(sender)
               try:
                  operators.remove(sender)
               except ValueError:
                  pass
               try:
                  halfoperators.remove(sender)
               except ValueError:
                  pass
            except ValueError:
               pass
         elif data[1][0] == "JOIN":
            sender = data[0].split("!")[0]
            targetchannel = data[1][1]
            if sender.lower() in tell_list.keys():
               try:
                  conn.privmsg(targetchannel, sender+" : "+" | ".join(tell_list[sender.lower()]))
                  del(tell_list[sender.lower()])
               except:
                  pass
            for useri,nicki in replacenames.items():
               checkers = Namecheck.Namecheck_dict(sender.lower(),replacenames)
               if checkers[0]:
                  try:
                     if checkers[0].lower() == sender:
                        pass
                     else:
                        conn.privmsg(targetchannel,checkers[1]+" : I have detected a collision with a name I call you and %s who joined" %(sender))
                        del(replacenames[checkers[1]])
                        with open("replacenames.cache","w") as pickle_save:
                           pickle.dump(replacenames,pickle_save)
                  except AttributeError:
                     #conn.privmsg(channel,"NAME COLLISION CHECK ERROR, RELATED TO %s" %(sender))
                     print "NAME COLLISION CHECK ERROR, RELATED TO %s" %(sender)
                     break
            print sender+" Has now joined"
            users.append(sender)
            #####
            if ".fi" in data[0] and sender.lower() == "skibiliano":
               operators.append(sender)
            if sender.lower() not in peopleheknows[0]:
               if data[0].split("!")[1] in peopleheknows[1]:
                  appendion = "...you do seem familiar however"
               else:
                  appendion = ""
               if data[1][1].lower() == channel or data[1][1].lower() == channel[1:]:
                   conn.privmsg(data[1][1],CORE_DATA.greeting.replace("USER",sender)+" "+appendion)
               else:
                  conn.privmsg(data[1][1],"Hello! Haven't seen you here before! Happy to meet you! %s" %(appendion))
               peopleheknows[0].append(sender.lower())
               peopleheknows[1].append(data[0].split("!")[1])
               with open("peopleheknows.cache","w") as peoplehecache:
                  pickle.dump(peopleheknows,peoplehecache)
                  
         elif data[1][0] == "MODE" and data[1][2] == "+o":
            sender = data[1][3]
            targetchannel = data[1][1]
            if targetchannel == channel:
               print sender+" Is now an operator on the main channel"
               operators.append(sender)
            else:
               print sender+" Is now an operator"
         elif data[1][0] == "MODE" and data[1][2] == "-o":
            sender = data[1][3]
            targetchannel = data[1][1]
            if targetchannel == channel:
               print sender+" Is no longer an operator on the main channel"
            else:
               print sender+" Is no longer an operator"
            try:
               operators.remove(sender)
            except ValueError:
               pass
         elif data[1][0] == "MODE" and data[1][2] == "+h":
            sender = data[1][3]
            print sender+" Is now an half operator"
            halfoperators.append(sender)
         elif data[1][0] == "MODE" and data[1][2] == "-h":
            try:
               halfoperators.remove(sender)
            except ValueError:
               pass
         elif data[1][0] == "MODE" and data[1][1] == Name:
            print "My mode is",data[1][2]
         elif data[1][0] == "MODE" and data[1][1] != Name:
            try:
               sender = data[1][3]
               print sender,"Was modified",data[1][2]
            except IndexError:
               print "SENDER RETRIEVAL FAILED:"+str(data)
         elif data[1][0] == "KICK" and data[1][2] == Name:
            disconnects = 99999
            print "I have been kicked! Disconnecting entirely!"
            conn.quit()
         elif data[1][0] == "KICK":
            # data[1][0] = Kick, 1 = Channel, 2 = Who, 3 = Who(?)
            print data[1][2]+" got kicked!"
         elif data[1][0] == "451" and data[1][2] == "You have not registered":
            print Name+" hasn't been registered"
         elif data[1][0] == "NOTICE":
            sender = data[0].split("!")[0]
            print "NOTICE (%s): %s" %(sender,data[1][2])
            pongtarget = sender
         elif data[1][0] == "NICK":
            origname = data[0].split("!")[0]
            newname = data[1][1]
            print origname,"Is now",newname
            if newname.lower() in tell_list.keys():
               try:
                  conn.privmsg(channel, newname+" : "+tell_list[newname.lower()][0])
                  del(tell_list[newname.lower()][0])
               except:
                  pass
            try:
               users.remove(origname)
            except ValueError:
               pass
            else:
               users.append(newname)
            try:
               operators.remove(origname)
            except ValueError:
               pass
            else:
               operators.append(newname)
            try:
               halfoperators.remove(origname)
            except ValueError:
               pass
            else:
               halfoperators.append(newname)
            
         elif data[1][0] == "001":
            # Skibot is welcomed to the Network
            pass
         elif data[1][0] == "002":
            # Your host is...
            pass
         elif data[1][0] == "003":
            #Server was created...
            pass
         elif data[1][0] == "004":
            #Weird hex?
            pass
         elif data[1][0] == "005":
            #Settings like NICKLEN and so on.
            pass
         elif data[1][0] == "250":
            #data[1][2] is
            #"Highest connection count: 1411 (1410 clients)
            #(81411 connections received)"
            pass
         elif data[1][0] == "251":
            #There are 23 users and 2491 invisible on 10 servers
            pass
         elif data[1][0] == "252":
            #IRC Operators online
            #data[1][2]
            print data[1][2],"Irc operators online"
            pass
         elif data[1][0] == "253":
            # ['253', 'Skibot_V4', '1', 'unknown connection(s)']
            print data[1][2],"Unknown connection(s)"
            pass
         elif data[1][0] == "254":
            #1391 channels formed
            pass
         elif data[1][0] == "255":
            #I have 406 clients and 2 servers
            pass
         elif data[1][0] == "265":
            #data[1][2] current local users
            #data[1][3] at max
            try:
               print "Current local users:", data[1][2],"/",data[1][3]
            except IndexError:
               print "Couldn't retrieve local users"
            pass
         elif data[1][0] == "266":
            #data[1][2] current global users
            #data[1][3] at max
            try:
               print "Current global users:", data[1][2],"/",data[1][3]
            except IndexError:
               print "Couldn't retrieve global users"
            pass
         elif data[1][0] == "315":
            #End of /who list
            pass
         elif data[1][0] == "332":
            # Topic of channel
            topic = data[1][3]
            pass
         elif data[1][0] == "333":
            # *Shrug*
            pass
         elif data[1][0] == "352":
            #WHO command

            if len(targetlist) > 0:
               if targetlist[0][0].lower() in data[1][6].lower():
                  thread.start_new_thread(target,("*!*@"+data[1][4],targetlist[0][1]))
                  print "Created a thread with", "*!*@"+data[1][4],targetlist[0][1]
                  targetlist.pop(0)
               else:
                  print targetlist[0][0].lower(), "isn't equal to?", data[1][6].lower()
                  print targetlist
               
         elif data[1][0] == "366":
            # End of USERS
            pass
         elif data[1][0] == "372":
            # Server information
            pass
         elif data[1][0] == "375":
            # Message of the day
            pass
         elif data[1][0] == "376":
            # End of motd
            pass
         elif data[1][0] == "401":
            # ('network', ['401','Botname','Channel / Nick','No such nick/channel'])
            print data[1][2] + " Channel does not exist"
            pass
         elif data[1][0] == "439":
            # ('irc.rizon.no', ['439', '*', 'Please wait while we process your connection.'])
            pongtarg = data[0][0]
         elif data[1][0] == "477":
            # You need to be identified
            #TAG
            conn.privmsg("nickserv","identify %s"%CORE_DATA.le_pass)
            time.sleep(0.5)
            conn.join(data[1][2])
            #('network', ['477', 'botname', '#channel', 'Cannot join channel (+r) - you need to be identified with services'])

         elif data[1][0] == "433":
            # Skibot name already exists.
            print Name+" name already exists."
            Name += "_"+version
            print "New name:",Name
            duplicate_notify = True
            conn = irchat.IRC ( Network, Port, Name, "NT_"+version, "NT_"+version, "Trasen_"+version )
            for i in CORE_DATA.channels:
               conn.join(i)
               sleep(0.5)
         elif data[1][0] == "482":
            sleep(0.05)
            conn.privmsg(targetchannel,"Nevermind that, I am not an operator")
            CALL_OFF = True
         elif data[1] == ["too","fast,","throttled."]:
            print "Reconnected too fast."
            print "Halting for 2 seconds"
            sleep(2)
         elif data[1][0] == "Link":
            if data[0] == "Closing":
               print "Link was closed"
               connected = False
#               conn.quit()
#               break
         else:
            print data
            print data[1][0]
            pass
   else:
      if disconnects > 9000: #IT'S OVER NINE THOUSAAAAND!
         break
      else: #WHAT NINE THOUSAND? THERE'S NO WAY THAT CAN BE RIGHT
         sleep(responsiveness_delay) #WAIT A WHILE AND CHECK AGAIN!
   try:
      if not connected:
         #print pongtarget
         #print conn.addressquery()
         conn.privmsg(pongtarget,"Pong")
         sleep(1)
         for i in CORE_DATA.channels:
            conn.join(i)
            sleep(0.5)
         print "Attempted to join"
         connected = True
   except ValueError:
      try:
         conn.privmsg(conn.addressquery()[0],"Pong")
         sleep(1)
         for i in CORE_DATA.channels:
            conn.join(i)
            sleep(0.5)
         print "Attempted to join the second time"
         connected = True
      except ValueError:
         print "Both methods failed"
   except AttributeError:
      print "Conn is not established correctly"
   except NameError:
      print "Pongtarget isn't yet established"
      try:
         conn.privmsg(conn.addressquery()[0],"Pong")
         sleep(1)
         for i in CORE_DATA.channels:
            conn.join(i)
            sleep(0.5)
         print "Attempted to join the second time"
         connected = True
      except:
         print "Both methods failed"
