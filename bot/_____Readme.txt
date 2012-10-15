/// Adminhelp relay IRC bot setup guide
/// CC_Nanotrasen bot created by Skibiliano and distributed under the CC-BY-SA 3.0 license
/// All derivative works of this bot must properly credit Skibiliano as the original author
/// Big thanks to Skibiliano  his bot and allowing distribution, and to BS12 for sharing their code for making use of it ingame

QUESTION: What does this bot do?
ANSWER: It, in conjunction with BYOND, relays adminhelps to a designated channel, along with various extra functions that can be accessed by saying !help in the same channel/in a query with the bot.

Some basic info before you set this up:
CC_Nanotrasen is coded in python 2.6 and requires a serverside installation of python 2.6 (obtainable at http://www.python.org/getit/releases/2.6/)
- Python MUST BE installed to the same directory as the .dmb you are using to host your server/server config folder
- CC_Nanotrasen supports, but does not require, Psyco (obtainable at http://psyco.sourceforge.net/download.html) which increases the speed 20-30% and slightly increases RAM usage

Now that that's out of the way, I'll teach you how to set this up.

BOT CONFIG:
Move everything in this folder (this file noninclusive) to the same folder as the hosting server (where your .dmb, config folder, and python are installed)
Open CORE_DATA.py with a text editor of your choice (recommended to be notepad++ or notepad)
You should see 14 lines of code which look like
			Name = "CC_NanoTrasen" #The name he uses to connect
			no_absolute_paths = True #Do not change this.
			debug_on = False
			SName = ["cc","nt","trasen","nano","nanotrasen"] #Other names he will respond to, must be lowercase
			DISABLE_ALL_NON_MANDATORY_SOCKET_CONNECTIONS = False
			directory = "BOT DIRECTORY GOES HERE/" #make sure to keep the "/" at the end
			version = "TG CC-BY-SA 6"
			Network = 'irc.server.goes.here' #e.g. "irc.rizon.net"
			channel = "#CHANNEL GOES HERE" #what channel you want the bot in
			channels = ["#CHANNEL GOES HERE","#ALSO ANOTHER CHANNEL GOES HERE IF YOU WANT"] #same as above
			greeting = "Welcome!" #what he says when a person he hasn't seen before joins
			prefix = "!" #prefix for bot commands
			Port = 7000
There are some basic comments besides every important config option in here, but I'll summarize them in detail
NAME - The name the bot assumes when it connects to IRC, so in this example it would join the IRC under the nickname "CC_Nanotrasen"
SNAME - A list of secondary names, with commas, that the bot will respond to for commands (for example, this setup will allow the bot to respond to "nt, tell quarxink he's a terrible writer")
DIRECTORY - The directory of the bot files, dmb, python, and config folder IN FORWARD SLASHES, WITH FORWARD SLASH AT THE END(for example, I host my test server from "c:\tgstation\tgstation13\tgstation.dmb" so for me the line would say directory = "c:/tgstation/tgstation13/")
NETWORK - The IRC server it will connect to, such as "irc.rizon.net"
CHANNEL/CHANNELS - what channel the bot will join (channels allows for multiple channel connections, in the same formatting as SName separates nicknames)
GREETING - CC_Nanotrasen will store the names of people it has seen before, but when a nickname joins that it hasn't seen before it will greet that person with whatever message is put in this
PREFIX = What character/string will be placed before commands for the bot (so if you changed this to "$", you would pull up the bot's help menu by saying $help instead of !help)
PORT - What port to connect to for the IRC server (if you are unsure of what port to use, most IRC clients will show you what port you are connecting to)

Once you have that ready, you're on to step two.
Open up the config folder in your install dir, and open config.txt
Scroll to the bottom, right below #FORBID_SINGULO_POSSESSION should be 
			##Remove the # mark if you are going to use the SVN irc bot to relay adminhelps
			#USEIRCBOT
Just remove the "#" in front of USEIRCBOT (you don't even have to recompile your DMB!

Got that all ready to go? Good, it's time for step three.
Open Dream Daemon (that thing you use when you host)
On the bottom of the window you should see port, security, and visibility.
Change security to "Trusted"

Congratulations, you've set up this bot!
A few things to note as far as features:
Use !help to list most commands for the bot.
You can leave notes for other users! Just say "[bot name], tell [other user's name] [message]"
	So let's say you wonder if I'm going to jump in to your IRC ever and you want to tell me this readme was horrible, you would say "Nano, tell Quarxink Your readme was horrible"

TROUBLESHOOTING:
Attempting to run the bot gives me an error about encoding.utf-8.
	You've probably installed python to a separate folder than the bot/server, move python's files over and it should run fine
	
It's telling me connection refused when someone adminhelps.
	You've moved the bot to a separate folder from the nudge script, most likely.
	
BYOND asks me on any restart if I want to allow nudge.py to run.
	Set security to trusted in Dream Daemon
	
	
	
	
If you have any requests, suggestions, or issues not covered by this guide, I can be contacted as Quarxink at #coderbus on irc.rizon.net (If I don't respond,  leave me a query with your problem and how to reach you [preferably an email address, steam, other irc channel, or aim/msn])