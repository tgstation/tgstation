/**global statics for the see_through_component coordinate maps
* For ease of use, include a comment in the shape of the coordinate map, where O is nothing, X is a hidden tile and A is the object
* List-coordinate layout is list(relative_x, relative_y, relative_z)
* Turf finding algorithm needs the z and you can totally use it, but I can't think of any reason to ever do it
* Also it'd be really cool if you could keep the list-coordinates in here represent their actual relative coords, dont use tabs though since their spacing can differ
*/
GLOBAL_LIST_INIT(see_through_maps, list(
	// X
	// A
	"default" = list(
	/*----------------*/list(0, 1, 0)
	),

	// XXX
	// XXX
	// XXX
	// OAO
	"3x3" = list(
		list(-1, 3, 0), list(0, 3, 0), list(1, 3, 0),
		list(-1, 2, 0), list(0, 2, 0), list(1, 2, 0),
		list(-1, 1, 0), list(0, 1, 0), list(1, 1, 0)
	),
	// X
	// X
	// A
	"default_two_tall" = list(
	/*----------------*/list(0, 2, 0),
	/*----------------*/list(0, 1, 0)
	),
	// XXX
	// XXX
	// OAO
	"3x2" = list(
		list(-1, 2, 0), list(0, 2, 0), list(1, 2, 0),
		list(-1, 1, 0), list(0, 1, 0), list(1, 1, 0)
	)
))

//For these defines, check also above for their actual shapes in-game and maybe get a better idea

///Default shape. It's one tile above the atom
#define SEE_THROUGH_MAP_DEFAULT GLOB.see_through_maps["default"]
///A 3x3 area 2 tiles above the atom (trees love to be this shape)
#define SEE_THROUGH_MAP_THREE_X_THREE GLOB.see_through_maps["3x3"]
///2 tiles above the atom
#define SEE_THROUGH_MAP_DEFAULT_TWO_TALL GLOB.see_through_maps["default_two_tall"]
///two rows of three tiles above the item (small but thick trees love these)
#define SEE_THROUGH_MAP_THREE_X_TWO GLOB.see_through_maps["3x2"]
