In-Hand DMI Compile System
==========================

A shitty hack by N3X15

WHY THE FUCK?
-------------

BYOND 499 limited the number of icon states that can be
added to a DMI to 512 states.  Why?  Who fucking knows.
Magically, DM can't edit them but the server doesn't
care how big they are, so it's probably a shitty hack
so they don't have to change the array's index type.

Whatever the case, we ran into this wall.  You cannot edit
items_lefthand and items_righthand with BYOND anymore.  We
filed a bug report: http://www.byond.com/forum/?post=1507331

They closed it with "Not a Bug".

So, here we are.  The only way to edit DMIs that big 
is with third-party tools like BYONDTools.

How to Compile
--------------

1. [Install BYONDTools](http://ss13.nexisonline.net/wiki/User:N3X15/Guide_to_BYONDTools).
2. Dump your DMIs into the appropriate folder. (Left-hand crap into the left-hand folder, etc.)
3. Open your command prompt. (cmd.exe on Windows)
4. Run the following (with the correct paths, of course):

```
cd icons/mobs/in-hand
ss13_makeinhands
```

buildIcons.bat in the root folder of this repository will do steps 3-4 for you, if you're on Windows.

Adding More Output Targets
--------------------------

If you've run into the problem mentioned above with another
DMI, have no fear:  Just edit compile.py and add the new
output target to the ToBuild dict as shown in the comments.

License
-------

MIT
