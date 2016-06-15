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
