So you want to work with cards eh?
Aight, so a few things before you start.

For more details on the formats read Format.txt. It goes further in depth on how this all works, and what means what.
For our purposes you only need to know a couple things.
There are 2 formats we use to edit and add cards. One is made to be interfaced by you, and one by dreammaker
I'll be covering the first for now.

There are a couple variables that we store. You can modify any one of these.

name //A fluff term displayed to the players
desc //A more detailed fluff term displayed to the players
icon //The icon source of the card
icon_state //The icon state of the card
id //A unique id issued to each card for lookups and storage. May contain any number > 0 that has not yet been used
power //A statistic used for fights. May contain any char from 0-9 in any amount
resolve //A statistic used for fights. May contain any char from 0-9 in any amount
tags //A tagging system to be used for formulating packs and adding behavior in the future
     //A tag may be any sequence of chars except |, $ or &
     //Stacking tags: To stack tags, place a & between each. For instance CE&NERD
cardtype //A string that allows us to define the use of the card ingame
rarity // The rarity of the card, based off the set it's called by

Here's how the readable format works.
\n (Newline) If alone, indecates that the current card def has ended and that we need to start a new one
: Tells the compiler to look for a variable name and value
= The varaiable name is on the right, the value is on the left

Now then, lets define a card. Hell let's make bubblegum

:name = Bubblegum
:desc = A bloody mix of cardboard and death
:icon = icons/obj/tcg.dmi
:icon_State = bubblegum
:id = 1
:power = 10
:resolve = 13
:tags = BLOODY&DEMON&LAVALAND
:cardtype = monster

Now a couple things you may have noticed.
Icon is a direct copy of how we define items in game. Seems like we could define that at a higher level.

This is why we have templates.

A template can be defined seperatly and referanced at the begining of the card.
This is done by defining a new type called template. Defining and referancing a template are 2 diffrent things.
Templates also need id's, but they have their own pool.
They allow us to insert info from the template into the card.

For instance:

:template = Demon
:name = Bloodlord
:icon = icons/obj/tcg.dmi
:id = 1
:tags = DEMON
:cardtype = monster

:template = $Demon
:name = $ Bubblegum
:desc = A bloody mix of cardboard and death
:icon_State = bubblegum
:id = 1
:power = 10
:resolve = 13
:tags = BLOODY&$&LAVALAND

Merged:

:name = Bloodlord Bubblegum
:desc = A bloody mix of cardboard and death
:icon = icons/obj/tcg.dmi
:icon_State = bubblegum
:id = 1
:power = 10
:resolve = 13
:tags = BLOODY&DEMON&LAVALAND
:cardtype = monster

Couple things to go over here. Bubblegum referances the Demon template, and also has some instances of $
Outside of the template def (See the first line of bubblegum's def) $ is a referance to whatever value the template has for the index.

So :name = $ Bubblegum is really :name = Bloodlord Bubblegum
Values that are not defined in the child template are carried over from the parent template

One last thing about templates. There is a default template that is applied to all cards after everthing else completes.
This template should define intentionally bugged behavior, like -power, things like that. This excepts icon, which can be used normaly

Now, onto how to turn this "$Sec|0,$ Pluto KV|3,detective|4,2|" into the stuff you see above.

TCGFileSystem.py is a python module built to transfer between the two file types.
It has 2 commands:
extract or ex
and insert or is

Both of these commands take in 2 files, and will transfre the data between both.
extract will take file1's contents, make it readable, and write it to file2
insert will do the same, except it will compress rather then expand

A note on rarity:
A card is picked by rarity by rolling a random number between 1 and the sum total of the raritys, and going through each rarity bracket, subtracting the random number by the value of the bracket. When the value is equal to or less then 0, we get our bracket, and get a random card that has that bracket as its rarity.
