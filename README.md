MiniStation Mod
================================

Code: https://github.com/tgstation/-tg-station

Original TG Station
================================

tgstation13 v1.0 - 6 October 2010

Website: http://nanotrasen.com
Code: https://github.com/tgstation/-tg-station
IRC: irc://irc.rizon.net/tgstation13

Mini-TG station
==

Brief
=

**What is it?**

A mod of tgstation 13 ( https://github.com/tgstation/-tg-station ) that is modified for low population servers; with simplified jobs, maps, duties and command structure.

**Who is the target audience?**

Server hosters who want to host a server for a player count of around 5 to 20 people.

**What about the map?**

Again, it will be changed, downsized and will have only the necessities to have a rich low population round.

Details
=

**Which jobs will be changed exactly?**

Since many jobs are going to be merged into each other, I will list what jobs the station will have and their purpose.

 * Captain - Make sure your station is running.
 * Lieutenant - Protect the Captain and be his right hand man.
 * Cargo Miner x2 - Running cargo bay and taking requests from other departments.
 * Bartender - Keeping the bar, serving drinks and food.
 * Janitor - Cleans the station.
 * Station Engineer x3 - Keeping the power running and fixing station damage.
 * Security Officer x2 - Protecting the crewmembers and serving space law.
 * Detective - Using forensic science to help security officers catch criminals.
 * Scientist x2 - Research and development of new technologies. Create bombs.
 * Medical Doctor x2 - Healing the crew. Cloning dead crew.
 * Chemist - Creating useful chemicals.
 * Unemployed x∞ - Not in charge at all. Basically the assistant of TG.

There will be 15 jobs (not including Unemployed) available on mini-TG station. There is a more simplified command system, with the Captain being the big boss and the Lieutenant being second in command. The heads will have control over all departments and jobs.

**What else has changed?**

Game Modes have been changed to accommodate the low population count. All except traitor, changeling, revolution and extended are disabled by default. You can change this in the config file.

There will only be one antag in changeling or traitor. In revolution there will be two rev-heads. Due to no starting AI, there is no malfunction; so I don’t advise enabling it. There are no plans to add a starting AI but you are still able to construct an AI.

Radio headsets will now only work with the department channels, using a handheld radio or intercom is required.

**Current Goal:**

 * Create a new map.

**Map Screenshots** (Please note that the map is under construction and is subject to change):

http://imgur.com/a/bjZ7X/all

INSTALLATION
============

First-time installation should be fairly straightforward.  First, you'll need
BYOND installed.  You can get it from http://www.byond.com/.  Once you've done 
that, extract the game files to wherever you want to keep them.  This is a
sourcecode-only release, so the next step is to compile the server files.
Open tgstation.dme by double-clicking it, open the Build menu, and click
compile.  This'll take a little while, and if everything's done right you'll get
a message like this:

saving tgstation.dmb (DEBUG mode)

tgstation.dmb - 0 errors, 0 warnings

If you see any errors or warnings, something has gone wrong - possibly a corrupt
download or the files extracted wrong.

Once that's done, open up the config folder.  You'll want to edit config.txt to
set the probabilities for different gamemodes in Secret and to set your server
location so that all your players don't get disconnected at the end of each
round.  It's recommended you don't turn on the gamemodes with probability 0, 
except Extended, as they have various issues and aren't currently being tested,
so they may have unknown and bizarre bugs.  Extended is essentially no mode, and
isn't in the Secret rotation by default as it's just not very fun.

You'll also want to edit admins.txt to remove the default admins and add your
own.  "Game Master" is the highest level of access, and the other recommended admin
levels for now are "Game Admin" (a little below host) and "Moderator".  The format is

byondkey - Rank

where the BYOND key must be in lowercase and the admin rank must be properly
capitalised.  There are a bunch more admin ranks, but these three should be
enough for most servers, assuming you have trustworthy admins.

Finally, to start the server, run Dream Daemon and enter the path to your
compiled tgstation.dmb file.  Make sure to set the port to the one you 
specified in the config.txt, and set the Security box to 'Safe'.  Then press GO
and the server should start up and be ready to join.

UPDATING
============

To update an existing installation, first back up your /config and /data folders
as these store your server configuration, player preferences and banlist.

Then, extract the new files (preferably into a clean directory, but updating in
place should work fine), copy your /config and /data folders back into the new
install, overwriting when prompted except if we've specified otherwise, and
recompile the game.  Once you start the server up again, you should be running
the new version.

SQL Setup
============

The SQL backend for the library and stats tracking requires a 
MySQL server.  Your server details go in /config/dbconfig.txt, and the SQL 
schema is in /SQL/tgstation_schema.sql.  More detailed setup instructions are
coming soon, for now ask in our IRC channel.

IRC Bot Setup
============

Included in the SVN is an IRC bot capable of relaying adminhelps to a specified IRC channel/server (thanks to Skibiliano)
Instructions for bot setup are included in the /bot/ folder along with the bot/relay script itself