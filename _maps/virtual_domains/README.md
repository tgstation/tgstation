# Making new virtual domains

## From scratch

1. Create a new map using TGM format. It can be any size, but please, consider limiting to 75x75 max.
2. Ensure that the map has ONE area marked safehouse bottom left. If you're using modular safehouses, it will need to be a 7x6 area.
4. Provide a way for players to enter your new map via the north door, which is 4th tile over. 
5. Enclose your area with a single wall binary closed wall.

## From an existing map

1. Copy and paste the map into the `_maps\virtual_domains` folder.
2. Find an accessible area for a safehouse, 7x6 - or with a custom, just ensure the necessary effects are placed.
3. Place a bottom left safehouse area somewhere on the map to load the safehouse.

### Notes

You shouldn't need to fully enclose your map in 15 tiles of binary filler. Using one solid wall should do the trick.

Adding some open tile padding around the safehouse is a good touch. About 7 tiles West/East for the visual effect of a larger map.

If you want to add prep gear, you can do so within the safehouse's area as long you don't overlap with goal turfs or exit spawners. The top left corner is a good spot for this, with respect for the walls, therefore [1, 1], [1, 2], [1, 3]

You can also create safehouses if you find yourself needing the same gear over and over again. There is a readme for that as well.

Boss zones should give players pretty ample space, I've been using a 23x23 minimum area.
