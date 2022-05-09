///each cell in a spatial_grid is this many turfs in length and width
#define SPATIAL_GRID_CELLSIZE 17

#define SPATIAL_GRID_CELLS_PER_SIDE(world_bounds) ROUND_UP((world_bounds) / SPATIAL_GRID_CELLSIZE)

#define SPATIAL_GRID_CHANNELS 2

//grid contents channels

///everything that is hearing sensitive is stored in this channel
#define SPATIAL_GRID_CONTENTS_TYPE_HEARING RECURSIVE_CONTENTS_HEARING_SENSITIVE
///every movable that has a client in it is stored in this channel
#define SPATIAL_GRID_CONTENTS_TYPE_CLIENTS RECURSIVE_CONTENTS_CLIENT_MOBS

///whether movable is itself or containing something which should be in one of the spatial grid channels.
#define HAS_SPATIAL_GRID_CONTENTS(movable) (movable.important_recursive_contents && (movable.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE] || movable.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS]))

// macros meant specifically to add/remove movables from lazy content lists in the spatial grid.
// when empty they become references to a single list in SSspatial_grid and when filled they become their own list
// this is to save memory without making them lazylists as that slows down iteration through them
#define GRID_CELL_ADD(cell_contents_list, movable_or_list) \
	if(!length(cell_contents_list)) { \
		cell_contents_list = list(); \
		cell_contents_list += movable_or_list; \
	} else { \
		cell_contents_list += movable_or_list; \
	};

#define GRID_CELL_SET(cell_contents_list, movable_or_list) \
	if(!length(cell_contents_list)) { \
		cell_contents_list = list(); \
		cell_contents_list += movable_or_list; \
	} else { \
		cell_contents_list |= movable_or_list; \
	};

//dont use these outside of SSspatial_grid's scope use the procs it has for this purpose
#define GRID_CELL_REMOVE(cell_contents_list, movable_or_list) \
	cell_contents_list -= movable_or_list; \
	if(!length(cell_contents_list)) {\
		cell_contents_list = dummy_list; \
	};
