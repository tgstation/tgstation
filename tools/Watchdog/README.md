VG-STATION WATCHDOG
===================
<em>Keeping Serbians in Line since 2013.</em>

This handy script will reboot your server automatically 
after it freezes or crashes.  

This is used on the /vg/station code testing server.

Requirements
------------

1. Python 2.7
2. git
3. Knowledge in making bash scripts/batch files
4. A brain

Setting Up
----------

1. Clone your server's code from github or another git repository to the directory you wish to run the server from.
2. Install BYOND.
3. Copy the config (or config-example, for /vg/-based servers) to a separate directory and edit as needed.  Moving configs elsewhere keeps them from being overwritten during updates.
4. Edit Watchdog.py to taste.  You will also need to edit the accompanying bash scripts to fit your environment.
5. Create the necessary scripts.
6. Optionally, edit your MOTD with the following macros (replaced when the config is copied over):
  * {GIT_BRANCH}: The desired branch in your git repository.
  * {GIT_REMOTE}: The name of the remote.
  * {GIT_COMMIT}: Shortened version of the current commit.

Usage
-----
Start Watchdog.py with python 2.7.  (If you're on linux, your best option would be to run it in a screen session.)

After starting, it will check if the repository requires an update.  If it does, it will 
fetch and pull the update, then compile the project using the script specified.  After 
this check, it will start the server.

60ish seconds after it starts, it will attempt to "ping" the configured server.  If no 
response is received, it will try restarting the server MAX_RETRIES times before the 
watchdog script errors out.

If the repository is detected to be out of date, it will again fetch and recompile.
