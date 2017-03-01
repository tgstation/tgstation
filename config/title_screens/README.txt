title_screens.dmi holds the image files used as the title screen for the game. To add more open the file in dream maker (it came with byond).

Working in the icon editor is easy, right click in the area with the images on the right hand side, select "import" and choose your title screen. 
Copying and pasting from image editing software also works.

Keep in mind that the area a title screen fills is a 480px square so you should scale/crop source images to these dimensions first.
The game won't scale these images for you, so smaller images will not fill the screen and larger ones will be cut off. 

You may add as many title screens as you like, if there is more than one a random screen is chosen (see name conventions for specifics).

---

Naming Conventions:

Every title screen you add must have a unique name. To name a title screen in dream maker, double click the space under the icon of it.


Common titles are in the rotation to be displayed all the time. Any name that does not include the character "+" is considered a common title.

An example of a common title name is "clown".

The common title screen named "default" is special. It is only used if no other titles are available. You can overwrite "default" safely, but you 
should have a title named "default" somewhere in your .dmi file if you don't have any other common titles. Because default only runs in the 
absence of other titles, if you want it to also appear in the general rotation you must rename it.


Map titles are tied to a specific in game map. To make a map title you format the name like this "(name of a map)+(name of your title)"

The spelling of the map name is important. It must match exactly the define MAP_NAME found in the relevant .DM file in the /_maps folder in 
the root directory. It can also be seen in game in the status menu. Note that there are no spaces between the two names.

An example of a map title name is "Omegastation+splash".


Rare titles are a just for fun feature where they will only have a 1% chance of appear in in the title screen pool of a given round.
Add the phrase "rare+" to the beginning of the name. Again note there are no spaces. A title cannot be rare title and a map title. You must choose.

An example of a rare title name is "rare+explosion"