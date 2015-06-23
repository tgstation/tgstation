#As new commands are added, update this.
# Last updated: 8.3.2011

# Updated 12.3.2011:
# - Added the missing help data for Version
# - Imported CORE_DATA to get the name.
# - Tidied some commands up a bit.
# - Replaced all "Bot"s with the Skibot's current name.

from CORE_DATA import Name
everything = {"8ball":"[8ball <arg>] Responds to the argument",
              "allcaps":"[allcaps <arg>] Takes an uppercase string and returns a capitalized version",
              "bmaths":"[bmaths <arg>] Takes a math equation (Like 5+5) and returns a binary result",
              "coin":"[coin] Flips a coin",
              "dance":"[dance] Makes %s do a little dance" %(Name),
              "delquote":"(OP ONLY) [delquote <arg>] Removes a quote with the filename equal to the argument",
              "disable":"(OP ONLY) [disable] Disables all output from %s" %(Name),
              "disable dance":"(HALFOP / OP ONLY) [disable dance] or [dd] Toggles dancing",
              "disable fml":"(HALFOP / OP ONLY) [disable fml] Disables FML",
              "eightball":"[eightball <arg>] Responds to the argument",
              "enable":"(OP ONLY) [enable] After being disabled, enable will turn output back on",
              "enable fml":"{HALFOP / OP ONLY} [enable fml] After fml has been disabled, enable fml will make it available again",
              "fml":"[fml] Returns a random Fuck My Life bit",
              "give":"[give <arg>] Gives the Pneumatic Disposal Unit the argument",
              "help":"[help [<command>]] Returns the list of commands or a detailed description of a command if specified",
              "hmaths":"[hmaths <arg>] Takes a math equation (Like 5+5) and returns a hex result",
              "makequote":"[makequote <arg>] Creates a quote with arg being the quote itself",
              "maths":"[maths <arg>] Takes a math equation (Like 5+5) and returns a default result",
              "note":"[note <arg1> [<arg2>]] Opens a note if only arg1 is specified, Creates a note with the name of arg1 and contents of arg2 if arg2 is specified, if you prefix the note name with [CP], it creates a public note only to that channel. Which can be accessed by !note _<note name>",
              "notes":"[notes] Displays all your saved notes on %s" %(Name),
              "otherball":"[otherball] If Floorbot is on the same channel, %s will ask him a random question when this command is passed" %(Name),
              "purgemessages":"[purgemessages] Used to delete all your Tell messages (%s,Tell <User> <Message>)" %(Name),
              "quote":"[quote [<author>]] Picks a random quote, if the author is specified, a random quote by that author",
              "redmine":"[redmine] If you have a note called redmine, with a valid whoopshop redmine address, this displays all the bugs labeled as 'New' on that page. It also displays the todo note if it's found.",
              "replace":"[replace] Fixes the Pneumatic Smasher if it's been broken",
              "rot13":"[rot13 <arg>] Encrypts the arg by using the rot13 method",
              "rtd":"[rtd [<arg1>d<arg2>]] Rolls a six-sided dice if no arguments are specified, otherwise arg1 is the amount of rolls and arg2 is the amount of sides the dice have",
              "sarcasticball":"[sarcasticball <arg>] Responds to the argument sarcastically",
              "sball":"[sball <arg>] Responds to the argument sarcastically",
              "srtd":"[srtd <arg1>d<arg2>] Rolls <arg1> amount of <arg2> sided die without showing the dice values separately",
              "stop":"(RESTRICTED TO OP AND CREATOR) [stop] Stops %s, plain and simple" %(Name),
              "suggest":"[suggest <arg>] Saves a suggestion given to %s, to be later viewed by the creator" %(Name),
              "take":"[take <arg>] Takes an item specified in the argument from the Pneumatic Smasher",
              "tban":"(OP ONLY) [tban <user> <seconds>] When %s is an operator, You can ban an user for specified amount of seconds" %(Name),
              "thm":"(RESTRICTED TO OP AND CREATOR) [thm] Normally in 8ball and sarcasticball, Users are not shown, instead replaced by things like demons or plasma researchers, toggling this changes that behaviour.",
              "tm":"(OP AND CREATOR ONLY) [tm] Toggles marakov",
              "togglequotemakers":"(OP ONLY) [togglequotemakers or tqm] Normally with the quote command, makers are not shown, this toggles that behaviour.",
              "tqm":"(OP ONLY) [tqm or togglequotemakers] Normally with the quote command, makers are not shown, this toggles that behaviour.",
              "toggleofflinemessages":"(OP ONLY) [toggleofflinemessages or tom] Allows an operator to toggle leaving Tell messages (%s, Tell <User> <Message)" %(Name),
              "tom":"(OP ONLY) [tom or toggleofflinemessages] Allows an operator to toggle leaving Tell messages (%s, Tell <User> <Message)" %(Name),
              "toggleyoutubereveal":"(OP ONLY) [toggleyoutubereveal] or [tyr] Toggles the automatic showing of youtube video titles based on URL's.",
              "tyr":"(OP ONLY) [tyr] or [toggleyoutubereveal] Toggles the automatic showing of youtube video titles based on URL's.",
              "translate":"(OP ONLY) [translate <user>] Whenever the user says something in allcaps, it's capitalized.",
              "uptime":"[uptime] Displays how long %s has been alive on the channel."%(Name),
              "use":"[use] Uses the Pneumatic Smasher.",
              "youtube":"[youtube <url>] Shows the title of a video by checking the URL provided.",
              "version":"[version] Shows the current version of %s." %(Name),
              "weather":"[weather <location>] Displays the current weather of the provided location.",
              "life":"I cannot help you with that, sorry."}
              
