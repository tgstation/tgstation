These folders hold the image files used as the title screen for the game. 

You may add as many title screens as you like, if there is more than one a random screen is chosen (see explanation of folders for specifics).

Don't put things that aren't .DMI files in these subfolders. Place any required non-image files in this folder instead.

Set the iconstate of all .DMI images to "title" (the iconstate is that text box located under the image in Dream Maker).

Only use one image per .DMI file.

If no valid screens are found the old screen found at /icons/misc/fullscreen.dmi will be used instead.

Keep in mind that the area a title screen fills is a 480px square so you should scale/crop source images to these dimensions first.
The game won't scale these images for you, so smaller images will not fill the screen and larger ones will be cut off. 
Note that using a title screen that is extremely large (> 1000px) needlessly can cause issues for clients, so keep them at or near that 480px ideal.

---

Explanation of Folders:

/_Always: Images in the /_Always folder will always be in rotation.

/[name of a map]: Images in these folders are specific to their associated maps. The name of the folder is important.
It must match exactly the define MAP_NAME found in the relevant .DM file in the /_maps folder in the root directory.

/_Rare: Images in the /_Rare folder have only a 1% chance of being added to the pool of valid images every round. Just for fun :o).