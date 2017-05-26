# .dmi Alphabetical sorter
Takes .dmi files and sorts them in place. See -h for information on use.
You should REALLY think about resaving files after you use this program on it.
When run from the cmd line it prints out every file that it touches, if a file is on that list
it needs to be resaved so that the metadata is what byond expects. Now I know that it will run
without resaving (byond's current version doesn't seem to care) but future versions may not.
And for small files the file is usually bigger (especially paletted pngs, since they have a bug
in the Pillow library afaik, or I'm incapable of the mental gymnastics to fix it) before you resave.
also paths like ..\..\icons should work fine when used with the recurser while on windows.
Mileage on other operating systems may vary.
## Requirements
* Python 3.X
* **Do not have PIL installed** it messes with Pillow, you should know if you have it.
* [Python Pillow](https://python-pillow.org/) (easy mode is "pip install Pillow" if you have pip)
## Other Notes
This program only runs on .dmi files so it should be safe to run it anywhere.
If you feel like changing how the sort works, change the function atoz(key) knowing that
key is a list in the form:

["icon name", directions, frames, "extra data as a string",[list of icons]]

directions*frames is the number of icons.
I tried to make this modular, so feel free to rip it apart and use bits of it.
Try to give me credit where credit is due though :P
-NINX3
