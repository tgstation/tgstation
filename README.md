##/tg/station v1.0.1 

[![Build Status](https://travis-ci.org/tgstation/-tg-station.png)](https://travis-ci.org/tgstation/-tg-station)


**Website:** http://www.tgstation13.org <BR>
**Code:** https://github.com/tgstation/-tg-station <BR>
**Wiki** http://tgstation13.org/wiki/Main_Page <BR>
**IRC:** irc://irc.rizon.net/coderbus or if you dont have an IRC client, you can click  [here](https://kiwiirc.com/client/irc.rizon.net:6667/?&theme=cli#coderbus).<BR>


##DOWNLOADING

There are a number of ways to download the source code. Some are described here, an alternative all-inclusive guide is also located at http://www.tgstation13.org/wiki/Downloading_the_source_code

Option 1:
Follow this: http://www.tgstation13.org/wiki/Setting_up_git

Option 2:
Install GitHub::windows from http://windows.github.com/
It handles most of the setup and configuraton of Git for you.
Then you simply search for the -tg-station repository and click the big clone
button.

Option 3: Download the source code as a zip by clicking the ZIP button in the
code tab of https://github.com/tgstation/-tg-station
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
and the server should start up and be ready to join.

###HOSTING ON LINUX
We use BYGEX for some of our text replacement related code. Unfortunately, we
only have a windows dll included right now. You can find a version known to compile on linux, along with some basic install instructions here
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

/tg/station currently comes equipped with three maps.

* [tgstation2 (default)](http://tgstation13.org/wiki/Boxstation)
* [MiniStation](http://tgstation13.org/wiki/MiniStation)
* [AsteroidStation](https://tgstation13.org/wiki/AsteroidStation)

All maps have their own code file that is in the base of the _maps directory. Instead of loading the map directly we instead use a code file to include the map and then include any other code changes that are needed for it; for example MiniStation changes the uplink items for the map. Follow this guideline when adding your own map, to your fork, for easy compatibility.

If you want to load a different map, just open the corresponding map's code file in Dream Maker, make sure all of the other map code files are unticked in the file tree, in the left side of the screen, and then make sure the map code file you want is ticked.

Anytime you want to make changes to a map it's imperative you use the [Map Merging tools](http://tgstation13.org/wiki/Map_Merger)

##AWAY MISSIONS

/tg/station supports loading away missions however they are disabled by default.

Map files for away missions are located in the _maps/RandomZLevels directory. Each away mission includes it's own code definitions located in /code/modules/awaymissions/mission_code. These files must be included and compiled with the server beforehand otherwise the server will crash upon trying to load away missions that lack their code.

To enable an away mission open fileList.txt in the _maps/RandomZLevels directory and uncomment one of the .dmm lines by removing the #. If more than one away mission is uncommented then the away mission loader will randomly select one the enabled ones to load.

##SQL SETUP

The SQL backend for the library and stats tracking requires a 
MySQL server.  Your server details go in /config/dbconfig.txt, and the SQL 
schema is in /SQL/tgstation_schema.sql and /SQL/tgstation_schema_prefix.sql depending on if you want table prefixes.  More detailed setup instructions are located here: http://www.tgstation13.org/wiki/Downloading_the_source_code#Setting_up_the_database

##IRC BOT SETUP

Included in the repository is an IRC bot capable of relaying adminhelps to a specified
IRC channel/server (thanks to Skibiliano).
Instructions for bot setup are included in the /bot folder along with the script
itself

##CONTRIBUTING

Please see [CONTRIBUTING.md](CONTRIBUTING.md)

##LICENSE

All code after commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST (https://github.com/tgstation/-tg-station/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under GNU AGPL v3 (http://www.gnu.org/licenses/agpl-3.0.html).
All code before commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST (https://github.com/tgstation/-tg-station/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under GNU GPL v3 (https://www.gnu.org/licenses/gpl-3.0.html).

including tools unless their readme specifies otherwise. See LICENSE-AGPLv3.txt and LICENSE-GPLv3.txt for more details.
All content including icons and sound is under a Creative Commons 3.0 BY-SA
license (http://creativecommons.org/licenses/by-sa/3.0/).
