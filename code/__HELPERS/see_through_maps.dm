//global statics for the see_through_component coordinate maps
//For ease of use, include a comment in the shape of the coordinate map, where O is nothing, X is a hidden tile and A is the object
GLOBAL_LIST_INIT(see_through_maps, list(
	// X
	// A
	"default" = list(
						list(0, 1, 0)
	),

	// XXX
	// XXX
	// OXO
	// OAO
	"pan_shape" = list(
		list(-1, 3, 0), list(0, 3, 0), list(1, 3, 0),
		list(-1, 2, 0), list(0, 2, 0), list(1, 2, 0),
					    list(0, 1, 0)
	),
	// X
	// X
	// A
	"default_two_tall" = list(
					   	list(0, 2, 0),
					   	list(0, 1, 0)
	)
))

#define SEE_THROUGH_MAP_DEFAULT GLOB.see_through_maps["default"]
#define SEE_THROUGH_MAP_PAN_SHAPE GLOB.see_through_maps["pan_shape"]
#define SEE_THROUGH_MAP_DEFAULT_TWO_TALL GLOB.see_through_maps["default_two_tall"]
