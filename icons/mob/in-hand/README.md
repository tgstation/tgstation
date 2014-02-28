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
is with third-party tools like OpenBYOND.

How to Compile
--------------

Simply dump your DMIs into the appropriate folder and run
compile.py from within this folder.  It'll build the DMIs
and jam everything into a single meta-DMI for you.

Simple.

Adding More Output Targets
--------------------------

If you've run into the problem mentioned above with another
DMI, have no fear:  Just edit compile.py and add the new
output target to the ToBuild dict as shown in the comments.

License
-------

MIT