The enclosed /sounds folder holds the sound files used for player selectable songs for an ingame jukebox.
OGG, WAV, and MP3 are supported. (I recommend verifying this is up to date with the list of `IS_SOUND_FILE_SAFE`)

Using unnecessarily huge sounds can cause client side lag and should be avoided.

You may add as many sounds as you would like.

---

Naming Conventions:

Every sound you add must have a unique name. Avoid using the plus sign "+" and the period "." in names, as these are used internally to classify sounds.

Sound names must be in the format of [song name]+[beat in deciseconds].ogg

beat is recommended but the code does not require it as its only used in the disco jukebox and UI

A song title "SS13" would have a file name SS13+5.ogg or SS13.ogg
