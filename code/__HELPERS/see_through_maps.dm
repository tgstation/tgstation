//For these defines, check also above for their actual shapes in-game and maybe get a better idea

///Default shape. It's one tile above the atom
#define SEE_THROUGH_MAP_DEFAULT "default"
///A 3x3 area 2 tiles above the atom (trees love to be this shape)
#define SEE_THROUGH_MAP_THREE_X_THREE "3x3"
///2 tiles above the atom
#define SEE_THROUGH_MAP_DEFAULT_TWO_TALL "default_two_tall"
///two rows of three tiles above the atom (small but thick trees love these)
#define SEE_THROUGH_MAP_THREE_X_TWO "3x2"
///One row of three tiles above the atom, but offset one tile to the left because of how billboards work
#define SEE_THROUGH_MAP_BILLBOARD "billboard"


/**global statics for the see_through_component coordinate maps
* For ease of use, include a comment in the shape of the coordinate map, where O is nothing, X is a hidden tile and A is the object
* List-coordinate layout is list(relative_x, relative_y, relative_z)
* Turf finding algorithm needs the z and you can totally use it, but I can't think of any reason to ever do it
* Also it'd be really cool if you could keep the list-coordinates in here represent their actual relative coords, dont use tabs though since their spacing can differ
*/
GLOBAL_LIST_INIT(see_through_maps, list(
	// X
	// A
	SEE_THROUGH_MAP_DEFAULT = list(
	/*----------------*/list(0, 1, 0)
	),

	// XXX
	// XXX
	// XXX
	// OAO
	SEE_THROUGH_MAP_THREE_X_THREE = list(
		list(-1, 3, 0), list(0, 3, 0), list(1, 3, 0),
		list(-1, 2, 0), list(0, 2, 0), list(1, 2, 0),
		list(-1, 1, 0), list(0, 1, 0), list(1, 1, 0)
	),

	// X
	// X
	// A
	SEE_THROUGH_MAP_DEFAULT_TWO_TALL = list(
	/*----------------*/list(0, 2, 0),
	/*----------------*/list(0, 1, 0)
	),

	// XXX
	// XXX
	// OAO
	SEE_THROUGH_MAP_THREE_X_TWO = list(
		list(-1, 2, 0), list(0, 2, 0), list(1, 2, 0),
		list(-1, 1, 0), list(0, 1, 0), list(1, 1, 0)
	),

	/// XXX
	/// OAO
	SEE_THROUGH_MAP_BILLBOARD = list(
		list(0, 1, 0), list(1, 1, 0), list(2, 1, 0)
	)
))


