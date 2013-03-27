tgstation13 v1.0 - 6 October 2010

Website: http://nanotrasen.com
Code: https://github.com/tgstation/-tg-station
IRC: irc://irc.rizon.net/tgstation13

================================================================================
DOWNLOADING
================================================================================
There are a number of ways to download tgstation13. I've listed 3 here (easiest first).

Option 1: Download the source code as a zip by clicking the ZIP button in the code tab of https://github.com/tgstation/-tg-station
(note: this will use a lot of bandwidth if you wish to update andis alot of hassle if you want to make any changes at all, so I don't recommend it)

(Option 2 & 3): Install Git-scm from here first: http://git-scm.com/download/win
Option 2:
Install GitHub::windows from http://windows.github.com/
It handles most of the setup/configuraton of Git for you.
Then you simply search for tgstation repository and click the big clone button.

Option 3:
Follow this guide linked in Giacom's post thread here: http://forums.nanotrasen.com/viewtopic.php?f=16&t=12552
(I recommend usng git-scm rather than the git CLI suggested by the guide linked to in that thread)


================================================================================
INSTALLATION
================================================================================

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

================================================================================
UPDATING
================================================================================

To update an existing installation, first back up your /config and /data folders
as these store your server configuration, player preferences and banlist.

Then, extract the new files (preferably into a clean directory, but updating in
place should work fine), copy your /config and /data folders back into the new
install, overwriting when prompted except if we've specified otherwise, and
recompile the game.  Once you start the server up again, you should be running
the new version.

================================================================================
SQL Setup
================================================================================

The SQL backend for the library and stats tracking requires a 
MySQL server.  Your server details go in /config/dbconfig.txt, and the SQL 
schema is in /SQL/tgstation_schema.sql.  More detailed setup instructions are
coming soon, for now ask in our IRC channel.

================================================================================
IRC Bot Setup
================================================================================

Included in the SVN is an IRC bot capable of relaying adminhelps to a specified IRC channel/server (thanks to Skibiliano)
Instructions for bot setup are included in the /bot/ folder along with the bot/relay script itself
