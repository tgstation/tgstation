# Making new virtual domains

## REQUIRED:
1. One way that the encrypted cache can spawn. This can be from a mob drop, a landmark (place a few, it'll pick one), or a signal landmark if you have a points system.
2. Place a virtual domain baseturf helper in each area.
3. If you're using modular safehouses, ensure that the map has ONE tile marked with the safehouse modular map loader (and set the KEY). it will need an open 7x6 area.
4. Placing a safehouse area is redundant, but it will ensure there is power in the starting safehouse.
5. Create the dm file that defines the map qualities. You can use the existing ones as a template.
6. Place a virtual domain baseturf helper in each area.

## Converting an existing map
1. Create a new map using the existing map's size - give yourself enough room to enclose it with a binary wall. There's no need for any space outside of it, so ensure that it fits and is enclosed, nothing outside of this.
2. Copy and paste the existing map into it.
3. Find an accessible area for a safehouse, 7x6.
4. Place a bottom left safehouse landmark somewhere on the map to load the safehouse.

## Notes
You shouldn't need to fully enclose your map in 15 tiles of binary filler. Using one solid wall should do the trick.

For areas, ideally just one on the map and one for the safehouse. Vdoms should never last so long as to need individual area power and atmos unless you're specifically going for a gimmick.

Make it modular: Add modular map and mob segments! It adds variety. Just make sure you've set your map to have "is_modular" afterwards.

Adding some open tile padding around the safehouse is a good touch. About 7 tiles West/East for the visual effect of a larger map.

If you want to add prep gear, you can do so within the safehouse's area as long you don't overlap with goal turfs or exit spawners. The top left corner is a good spot for this, with respect for the walls, therefore [1, 1], [1, 2], [1, 3]

You can also create a specific safehouse if you find yourself needing the same gear over and over again. There is a readme for that as well.

Boss zones should give players pretty ample space, I've been using a 23x23 minimum area.

While it's not a hard set rule, 75x75 is the guideline for max size. The main issue is keeping them in the domain for too long.

You have the option of baking in your own safehouse and ignoring the 7x6 guideline. To do this, you will still need a safehouse landmark and a file to load - even if it's empty. Ensure that you have the necessary landmarks placed that normally go in a safehouse on the map itself.
