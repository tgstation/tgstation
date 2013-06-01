# baystation12

[Website](http://baystation12.net/) - [Code](http://github.com/Baystation12/Baystation12/) - [IRC](http://baystation12.net/forums/viewtopic.php?f=12&t=5088)

---

### GETTING THE CODE
The simplest way to obtain the code is using the github .zip feature.

Click [here](https://github.com/Baystation12/Baystation12/archive/master.zip) to get the latest code as a .zip file, then unzip it to wherever you want.

The more complicated and easier to update method is using git.  You'll need to download git or some client from [here](http://git-scm.com/).  When that's installed, right click in any folder and click on "Git Bash".  When that opens, type in:

    git clone git@github.com:Baystation12/Baystation12.git

(hint: hold down ctrl and press insert to paste into git bash)

This will take a while to download, but it provides an easier method for updating.

### INSTALLATION

First-time installation should be fairly straightforward.  First, you'll need BYOND installed.  You can get it from [here](http://www.byond.com/).

This is a sourcecode-only release, so the next step is to compile the server files.  Open baystation12.dme by double-clicking it, open the Build menu, and click compile.  This'll take a little while, and if everything's done right you'll get a message like this:

    saving baystation12.dmb (DEBUG mode)
    
    baystation12.dmb - 0 errors, 0 warnings

If you see any errors or warnings, something has gone wrong - possibly a corrupt download or the files extracted wrong, or a code issue on the main repo.  Ask on IRC.

Once that's done, open up the config folder.  You'll want to edit config.txt to set the probabilities for different gamemodes in Secret and to set your server location so that all your players don't get disconnected at the end of each round.  It's recommended you don't turn on the gamemodes with probability 0, as they have various issues and aren't currently being tested, so they may have unknown and bizarre bugs.

You'll also want to edit admins.txt to remove the default admins and add your own.  "Game Master" is the highest level of access, and the other recommended admin levels for now are "Game Admin" and "Moderator".  The format is:

    byondkey - Rank

where the BYOND key must be in lowercase and the admin rank must be properly capitalised.  There are a bunch more admin ranks, but these two should be enough for most servers, assuming you have trustworthy admins.

Finally, to start the server, run Dream Daemon and enter the path to your compiled baystation12.dmb file.  Make sure to set the port to the one you  specified in the config.txt, and set the Security box to 'Trusted'.  Then press GO and the server should start up and be ready to join.

---

### UPDATING

To update an existing installation, first back up your /config and /data folders
as these store your server configuration, player preferences and banlist.

If you used the zip method, you'll need to download the zip file again and unzip it somewhere else, and then copy the /config and /data folders over.

If you used the git method, you simply need to type this in to git bash:

    git pull

When this completes, copy over your /data and /config folders again, just in case.

When you have done this, you'll need to recompile the code, but then it should work fine.

---

### SQL Setup

The SQL backend for the library and stats tracking requires a MySQL server.  Your server details go in /config/dbconfig.txt, and the SQL schema is in /SQL/tgstation_schema.sql.  More detailed setup instructions arecoming soon, for now ask in our IRC channel.

---

### IRC Bot Setup

Included in the repo is an IRC bot capable of relaying adminhelps to a specified IRC channel/server (thanks to Skibiliano).  Instructions for bot setup are included in the /bot/ folder along with the bot/relay script itself.
