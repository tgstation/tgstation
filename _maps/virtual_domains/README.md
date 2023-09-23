# Making new virtual domains

## From scratch

1. Create a new map using TGM format. It can be any size, but please, consider limiting to 75x75 max.
2. Ensure that the map has ONE tile marked with the safehouse bottom left landmark. If you're using modular safehouses, it will need to be a 7x6 area.
4. Provide a way for players to enter your new map via the north door, which is 4th tile over. 
5. Enclose your area with a single wall binary closed wall.

## From an existing map

1. Create a new map using the existing map's size - give yourself enough room to enclose it with a binary wall. There's no need for any space outside of it, so ensure that it fits and is enclosed, nothing outside of this.
2. Copy and paste the existing map into it.
3. Find an accessible area for a safehouse, 7x6 - or with a custom, just ensure the necessary landmarks are placed.
4. Place a bottom left safehouse landmark somewhere on the map to load the safehouse.

## BOTH.
1. You need to have one (1) way that the encrypted cache can spawn. This can be from a mob drop, a landmark (place a few, it'll pick one), or a signable landmark if you have a points system.
2. Make note of the size of the map. Make sure this is in the dm file.
3. Create the dm file that defines the map qualities. Examples are in the bitrunning file.

### Notes

You shouldn't need to fully enclose your map in 15 tiles of binary filler. Using one solid wall should do the trick.

Adding some open tile padding around the safehouse is a good touch. About 7 tiles West/East for the visual effect of a larger map.

If you want to add prep gear, you can do so within the safehouse's area as long you don't overlap with goal turfs or exit spawners. The top left corner is a good spot for this, with respect for the walls, therefore [1, 1], [1, 2], [1, 3]

You can also create safehouses if you find yourself needing the same gear over and over again. There is a readme for that as well.

Boss zones should give players pretty ample space, I've been using a 23x23 minimum area.
