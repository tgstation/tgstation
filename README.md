# baystation12

[Website](http://baystation12.net/) - [Code](http://github.com/Baystation12/Baystation12/) - [IRC](http://baystation12.net/forums/viewtopic.php?f=12&t=5088)

---

### INSTALLATION

First-time installation should be fairly straightforward.  First, you'll need
BYOND installed.  You can get it from http://www.byond.com/.  Once you've done 
that, extract the game files to wherever you want to keep them.  This is a
sourcecode-only release, so the next step is to compile the server files.
Open baystation12.dme by double-clicking it, open the Build menu, and click
compile.  This'll take a little while, and if everything's done right you'll get
a message like this:

    saving baystation12.dmb (DEBUG mode)
    
    baystation12.dmb - 0 errors, 0 warnings

If you see any errors or warnings, something has gone wrong - possibly a corrupt
download or the files extracted wrong.

It could be an issue with the current version of the code, either.  Ask on IRC
or wait for a fix.

Once that's done, open up the config folder.  You'll want to edit config.txt to
set the probabilities for different gamemodes in Secret and to set your server
location so that all your players don't get disconnected at the end of each
round.  It's recommended you don't turn on the gamemodes with probability 0, 
except Extended, as they have various issues and aren't currently being tested,
so they may have unknown and bizarre bugs.  Extended is essentially no mode, and
isn't in the Secret rotation by default as it's just not very fun.

You'll also want to edit admins.txt to remove the default admins and add your
own.  "Game Master" is the highest level of access, and the other recommended
admin level for now is "Game Admin".  The format is:

    byondkey - Rank

where the BYOND key must be in lowercase and the admin rank must be properly
capitalised.  There are a bunch more admin ranks, but these two should be
enough for most servers, assuming you have trustworthy admins.

Additionally, you can set up moderators in moderators.txt, with this format:

    byondkey

Moderators have access to player notes and a few other low-level commands.

Finally, to start the server, run Dream Daemon and enter the path to your
compiled baystation12.dmb file.  Make sure to set the port to the one you 
specified in the config.txt, and set the Security box to 'Trusted'.  Then press
GO and the server should start up and be ready to join.

---

### UPDATING

To update an existing installation, first back up your /config and /data folders
as these store your server configuration, player preferences and banlist.

Then, extract the new files (preferably into a clean directory, but updating in
place should work fine), copy your /config and /data folders back into the new
install, overwriting when prompted except if we've specified otherwise, and
recompile the game.  Once you start the server up again, you should be running
the new version.

---

### SQL Setup

The SQL backend for the library and stats tracking requires a 
MySQL server.  Your server details go in /config/dbconfig.txt, and the SQL 
schema is in /SQL/tgstation_schema.sql.  More detailed setup instructions are
coming soon, for now ask in our IRC channel.

---

### IRC Bot Setup

Included in the repo is an IRC bot capable of relaying adminhelps to a specified
IRC channel/server (thanks to Skibiliano).  Instructions for bot setup are
included in the /bot/ folder along with the bot/relay script itself.
