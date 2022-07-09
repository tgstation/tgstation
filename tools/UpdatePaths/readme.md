HOW TO USE:
Drag one of the scripts in the “Scripts” folder onto the .bat file “Update Paths” to open it with the .bat file. Let the script run. 

Use this tool before using mapmerge or opening the map in an editor.

IMPORTANT:
Please tie the script you are making to the associated PR on github and put it in the scripts folder when you are done.

For example: 67107_Turf_Updates_2

HOW TO MAKE A SCRIPT:
This tool updates paths in the game to new paths. For instance:
If you have a path labeled

/obj/structure/door/airlock/science/closed/rd

and wanted it to be

/obj/structure/door/airlock/science/rd/closed

This tool would update it for you! This is extremely helpful if you want to be nice to people who have to resolve merge conflicts from the PRs that you make updating these areas.

How do you do it?
Simply open a notepad and type this on a line:

/obj/structure/door/airlock/science/closed/rd : /obj/structure/door/airlock/science/rd/closed

The path on the left is the old, the path on the right is the new. It is seperated by a ":"
If you want to make multiple path changes in one script, simply add more changes on new lines.

If you get lost, look at other scripts for examples.

