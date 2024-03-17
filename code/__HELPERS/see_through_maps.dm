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
///Two rows of three wide, but offset one tile to the left because thats how shipping containers work
#define SEE_THROUGH_MAP_SHIPPING_CONTAINER "shipping_container"
///Seethrough component for the ratvar wreck, in shape of the ratvar wreck
#define SEE_THROUGH_MAP_RATVAR_WRECK "ratvar"


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
	/*----------------*/list(0, 1, 0),
	/*----------------*/list(0, 0, 0)
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
	/*----------------*/list(0, 1, 0),
	/*----------------*/list(0, 0, 0)
	),

	// XXX
	// XXX
	// OAO
	SEE_THROUGH_MAP_THREE_X_TWO = list(
		list(-1, 2, 0), list(0, 2, 0), list(1, 2, 0),
		list(-1, 1, 0), list(0, 1, 0), list(1, 1, 0)
	),

	/// XXX
	/// AOO
	SEE_THROUGH_MAP_BILLBOARD = list(
		list(0, 1, 0), list(1, 1, 0), list(2, 1, 0)
	),
	/// XXX
	/// AXX
	SEE_THROUGH_MAP_SHIPPING_CONTAINER = list(
		list(0, 1, 0), list(1, 1, 0), list(2, 1, 0),
		list(0, 0, 0), list(1, 0, 0), list(2, 0, 0)
	),
	//No
	SEE_THROUGH_MAP_RATVAR_WRECK = list(
		list(3, 5, 0), list(4, 5, 0), list(5, 5, 0), list(6, 5, 0),
		list(3, 4, 0), list(4, 4, 0), list(5, 4, 0), list(6, 4, 0), list(7, 4, 0), list(9, 4, 0),
		list(3, 3, 0), list(4, 3, 0), list(5, 3, 0), list(6, 3, 0), /* the neck */ list(8, 3, 0), list(9, 3, 0),
		list(0, 2, 0), list(1, 2, 0), list(2, 2, 0), list(3, 2, 0), list(4, 2, 0), list(5, 2, 0), list(6, 2, 0), list(7, 2, 0), list(8, 2, 0), list(9, 2, 0), list(10, 2, 0), list(11, 2, 0), list(12, 2, 0),
		list(0, 1, 0), list(1, 1, 0), list(2, 1, 0), list(3, 1, 0), list(4, 1, 0), list(5, 1, 0), list(6, 1, 0), list(7, 1, 0), list(8, 1, 0), list(9, 1, 0), list(10, 1, 0), list(11, 1, 0), list(12, 1, 0),
		list(0, 0, 0), list(1, 0, 0), list(2, 0, 0), list(3, 0, 0), list(4, 0, 0), list(5, 0, 0), list(6, 0, 0), list(7, 0, 0), list(8, 0, 0), list(9, 0, 0), list(10, 0, 0), list(11, 0, 0), list(12, 0, 0), list(13, 0, 0)
	)
))


