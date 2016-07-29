<<<<<<< HEAD
##/tg/station v1.0.1

[![Build Status](https://travis-ci.org/tgstation/tgstation.png)](https://travis-ci.org/tgstation/tgstation)


**Website:** http://www.tgstation13.org <BR>
**Code:** https://github.com/tgstation/tgstation <BR>
**Wiki** http://tgstation13.org/wiki/Main_Page <BR>
**IRC:** irc://irc.rizon.net/coderbus or if you dont have an IRC client, you can click  [here](https://kiwiirc.com/client/irc.rizon.net:6667/?&theme=cli#coderbus).<BR>


##DOWNLOADING

There are a number of ways to download the source code. Some are described here, an alternative all-inclusive guide is also located at http://www.tgstation13.org/wiki/Downloading_the_source_code

Option 1:
Follow this: http://www.tgstation13.org/wiki/Setting_up_git

Option 2:
Install GitHub::windows from http://windows.github.com/
It handles most of the setup and configuraton of Git for you.
Then you simply search for the tgstation repository and click the big clone
button.

Option 3: Download the source code as a zip by clicking the ZIP button in the
code tab of https://github.com/tgstation/tgstation
(note: this will use a lot of bandwidth if you wish to update and is a lot of
hassle if you want to make any changes at all, so it's not recommended.)

##INSTALLATION

First-time installation should be fairly straightforward.  First, you'll need
BYOND installed.  You can get it from http://www.byond.com/.  Once you've done
that, extract the game files to wherever you want to keep them.  This is a
sourcecode-only release, so the next step is to compile the server files.
Open tgstation.dme by double-clicking it, open the Build menu, and click
compile.  This'll take a little while, and if everything's done right you'll get
a message like this:

```
saving tgstation.dmb (DEBUG mode)
tgstation.dmb - 0 errors, 0 warnings
```

If you see any errors or warnings, something has gone wrong - possibly a corrupt
download or the files extracted wrong. If problems persist, ask for assistance
in irc://irc.rizon.net/coderbus

Once that's done, open up the config folder.  You'll want to edit config.txt to
set the probabilities for different gamemodes in Secret and to set your server
location so that all your players don't get disconnected at the end of each
round.  It's recommended you don't turn on the gamemodes with probability 0,
except Extended, as they have various issues and aren't currently being tested,
so they may have unknown and bizarre bugs.  Extended is essentially no mode, and
isn't in the Secret rotation by default as it's just not very fun.

You'll also want to edit config/admins.txt to remove the default admins and add
your own.  "Game Master" is the highest level of access, and probably the one
you'll want to use for now.  You can set up your own ranks and find out more in
config/admin_ranks.txt

The format is

```
byondkey = Rank
```

where the admin rank must be properly capitalised.

Finally, to start the server, run Dream Daemon and enter the path to your
compiled tgstation.dmb file.  Make sure to set the port to the one you
specified in the config.txt, and set the Security box to 'Safe'.  Then press GO
and the server should start up and be ready to join. It is also recommended that
you set up the SQL backend (see below).

###HOSTING ON LINUX
If you're not using BYOND version 510, BYGEX will be used for some text replacement related code. Unfortunately, we only have a windows dll included right now. You can find a version known to compile on linux, along with some basic install instructions here:
https://github.com/optimumtact/byond-regex

##UPDATING

To update an existing installation, first back up your /config and /data folders
as these store your server configuration, player preferences and banlist.

Then, extract the new files (preferably into a clean directory, but updating in
place should work fine), copy your /config and /data folders back into the new
install, overwriting when prompted except if we've specified otherwise, and
recompile the game.  Once you start the server up again, you should be running
the new version.

##MAPS

/tg/station currently comes equipped with seven maps.

* [tgstation2 (default)](http://tgstation13.org/wiki/Boxstation)
* [MetaStation](https://tgstation13.org/wiki/MetaStation)
* [MiniStation](http://tgstation13.org/wiki/MiniStation)
* [AsteroidStation](https://tgstation13.org/wiki/AsteroidStation)
* [BirdStation](https://tgstation13.org/wiki/BirdStation)
* [DreamStation](https://tgstation13.org/wiki/Dreamstation)
* [EfficiencyStation](https://tgstation13.org/wiki/Efficiency_Station)

All maps have their own code file that is in the base of the _maps directory. Instead of loading the map directly we instead use a code file to include the map and then include any other code changes that are needed for it; for example MiniStation changes the uplink items for the map. Follow this guideline when adding your own map, to your fork, for easy compatibility.

If you want to load a different map, just open the corresponding map's code file in Dream Maker, make sure all of the other map code files are unticked in the file tree, in the left side of the screen, and then make sure the map code file you want is ticked.

If you are hosting a server, and want randomly picked maps to be played each round, you can enable map rotation in [config.txt](config/config.txt) and then set the maps to be picked in the [maps.txt](config/maps.txt) file.

Anytime you want to make changes to a map it's imperative you use the [Map Merging tools](http://tgstation13.org/wiki/Map_Merger)

##AWAY MISSIONS

/tg/station supports loading away missions however they are disabled by default.

Map files for away missions are located in the _maps/RandomZLevels directory. Each away mission includes it's own code definitions located in /code/modules/awaymissions/mission_code. These files must be included and compiled with the server beforehand otherwise the server will crash upon trying to load away missions that lack their code.

To enable an away mission open fileList.txt in the _maps/RandomZLevels directory and uncomment one of the .dmm lines by removing the #. If more than one away mission is uncommented then the away mission loader will randomly select one the enabled ones to load.

##SQL SETUP

The SQL backend requires a MySQL server. SQL is required for the library, stats tracking, admin notes, and job-only bans, among other features, mostly related to server administration. Your server details go in /config/dbconfig.txt, and the SQL schema is in /SQL/tgstation_schema.sql and /SQL/tgstation_schema_prefix.sql depending on if you want table prefixes.  More detailed setup instructions are located here: http://www.tgstation13.org/wiki/Downloading_the_source_code#Setting_up_the_database

##IRC BOT SETUP

Included in the repository is a python3 compatible IRC bot capable of relaying adminhelps to a specified
IRC channel/server, see the /bot folder for more

##CONTRIBUTING

Please see [CONTRIBUTING.md](CONTRIBUTING.md)

##LICENSE

All code after commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST (https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under GNU AGPL v3 (http://www.gnu.org/licenses/agpl-3.0.html).

All code before commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST (https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under GNU GPL v3 (https://www.gnu.org/licenses/gpl-3.0.html).
(Including tools unless their readme specifies otherwise.)

See LICENSE-AGPLv3.txt and LICENSE-GPLv3.txt for more details.

tgui clientside is licensed as a subproject under the MIT license.
tgui assets are licensed under a Creative Commons Attribution-ShareAlike 4.0 International License
(http://creativecommons.org/licenses/by-sa/4.0/).

See tgui/LICENSE.md for more details.

All assets including icons and sound are under a Creative Commons 3.0 BY-SA
license (http://creativecommons.org/licenses/by-sa/3.0/) unless otherwise indicated.
=======
# vgstation

[Website](http://ss13.moe) - [Code](https://github.com/d3athrow/vgstation13)

[IRC](irc://irc.rizon.net/vgstation) (irc.rizon.net #vgstation), here is an embedded link to it

[![Visit our IRC channel](https://kiwiirc.com/buttons/irc.rizon.net/vgstation.png)](https://kiwiirc.com/client/irc.rizon.net/?nick=Newcomer|?&theme=basic#vgstation)

---

### GETTING THE CODE
The simplest but least useful way to obtain the code is using the Github .zip feature. You can click [here](https://gitlab.com/vgstation/vgstation/repository/archive.zip?ref=Bleeding-Edge) to get the latest stable code as a .zip file, then unzip it to wherever you want. Alternatively, a much more useful method is to use a git client, the process for getting and using one is described below, (for more information our coders in IRC can tell you how to use one).

### Git client

The more complicated but infinitely more useful way is to use a 'git' client.  

We recommend and support our users using the smartgit client, obtainable at [smartgit](http://www.syntevo.com/smartgit/). After installing it, create a new file folder where you want to host the code, right click on that folder and click on "Open in Smartgit".  

When that opens, click repository at the top left and choose 'clone'. You can either use the link for the main repository https://github.com/d3athrow/vgstation13.git, or to clone your own fork the format is https://github.com/USERNAME/REPONAME.git, just copy the URL at your fork and add .git.

#### Updating the Code

After you have cloned, make sure you have a remote to the main repository and your own forked repository by making a remote using the links above. By right clicking on your remote to this repo you can 'pull' the most recent version of the code from the main repository.

You can then create new branches of code directly from our Bleeding-Edge branch on your computer. 

Warning: If you checkout different branches or update the code while Dream Maker is open, this can cause problems when someone adds/removes files or when one of the files changed is currently open.

#### Branches

Keep in mind that we have multiple branches for various purposes.

* *master* - "stable" but ancient code, it was used on the main server until we realized we like living on the edge  :sunglasses:.
* *Bleeding-Edge* - The latest code, this code is run on the main server.  _Please do any development against this branch!_

### INSTALLATION

First-time installation should be fairly straightforward.  First, you'll need BYOND installed.  You can get it from [here](http://www.byond.com/).

This is a sourcecode-only release, so the next step is to compile the server files.  Open vgstation13.dme by double-clicking it, open the Build menu, and click compile.  This'll take a little while, and if everything's done right you'll get a message like this:

    saving vgstation13.dmb (DEBUG mode)

    vgstation13.dmb - 0 errors, 0 warnings

If you see any errors or warnings, something has gone wrong - possibly a corrupt download or the files extracted wrong, or a code issue on the main repo.  Ask on IRC.

To use the SQLite preferences, rename players2_empty.sqlite to players2.sqlite

Next, copy everything from config-example/ to config/ so you have some default configuration.

Once that's done, open up the config folder.  You'll want to edit config.txt to set the probabilities for different gamemodes in Secret and to set your server location so that all your players don't get disconnected at the end of each round.  It's recommended you don't turn on the gamemodes with probability 0, as they have various issues and aren't currently being tested, so they may have unknown and bizarre bugs.

You'll also want to edit admins.txt to remove the default admins and add your own.  "Host" is the highest level of access, and the other recommended admin levels for now are "Game Master", "Game Admin" and "Moderator".  The format is:

    byondkey - Rank

where the BYOND key must be in lowercase and the admin rank must be properly capitalized.  There are a bunch more admin ranks, but these two should be enough for most servers, assuming you have trustworthy admins.

Finally, to start the server, run Dream Daemon and enter the path to your compiled vgstation13.dmb file.  Make sure to set the port to the one you  specified in the config.txt, and set the Security box to 'Trusted'.  Then press GO and the server should start up and be ready to join.

---

### Configuration

For a basic setup, simply copy every file from config-example/ to config/ and then add yourself as admin via `admins.txt`.

---

### SQL Setup

The SQL backend for the library and stats tracking requires a MySQL server.  (Linux servers will need to put libmysql.so into the same directory as vgstation13.dme.)  Your server details go in /config/dbconfig.txt.

The database is automatically installed during server startup, but you need to ensure the database and user are present and have necessary permissions.

---

### IRC Bot Setup

Included in the repo is an IRC bot capable of relaying adminhelps to a specified IRC channel/server (replaces the older one by Skibiliano).  Instructions for bot setup are included in the /bot/ folder along with the bot/relay script itself.
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
