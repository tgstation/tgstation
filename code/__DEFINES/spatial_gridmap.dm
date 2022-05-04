///each cell in a spatial_grid is this many turfs in length and width
#define SPATIAL_GRID_CELLSIZE 17
///Takes a coordinate, and spits out the spatial grid index (x or y) it's inside
#define GET_SPATIAL_INDEX(chord) ROUND_UP((chord) / SPATIAL_GRID_CELLSIZE)
#define SPATIAL_GRID_CELLS_PER_SIDE(world_bounds) GET_SPATIAL_INDEX(world_bounds)

#define SPATIAL_GRID_CHANNELS 2

//grid contents channels

///everything that is hearing sensitive is stored in this channel
#define SPATIAL_GRID_CONTENTS_TYPE_HEARING RECURSIVE_CONTENTS_HEARING_SENSITIVE
///every movable that has a client in it is stored in this channel
#define SPATIAL_GRID_CONTENTS_TYPE_CLIENTS RECURSIVE_CONTENTS_CLIENT_MOBS
///all atmos machines are stored in this channel (I'm sorry kyler)
#define SPATIAL_GRID_CONTENTS_TYPE_ATMOS "spatial_grid_contents_type_atmos"

///whether movable is itself or containing something which should be in one of the spatial grid channels.
#define HAS_SPATIAL_GRID_CONTENTS(movable) ((\
	movable.important_recursive_contents && (\
	movable.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE] || movable.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS]))\
	|| movable.flags_1 & SPATIAL_GRID_MANAGED_1)
