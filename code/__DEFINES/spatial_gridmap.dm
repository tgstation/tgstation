///each cell in a spatial_grid is this many turfs in length and width
#define SPATIAL_GRID_CELLSIZE 15
//the inverse of the above, because i heard that multiplication is *slightly* faster than division
//and thats like the one assumption i didnt test at all :trollface:
#define INVERSE_SPATIAL_GRID_CELLSIZE (1 / SPATIAL_GRID_CELLSIZE)

#define SPATIAL_GRID_CELLS_PER_SIDE ROUND_UP(world.maxx * INVERSE_SPATIAL_GRID_CELLSIZE)

#define SPATIAL_GRID_CHANNELS 2

//grid contents channels

///everything that is hearing sensitive is stored in this channel
#define SPATIAL_GRID_CONTENTS_TYPE_HEARING RECURSIVE_CONTENTS_HEARING_SENSITIVE
///every movable that has a client in it is stored in this channel
#define SPATIAL_GRID_CONTENTS_TYPE_CLIENTS RECURSIVE_CONTENTS_CLIENT_MOBS

#define HAS_SPATIAL_GRID_CONTENTS(movable) (movable.important_recursive_contents && (movable.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE] || movable.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS]))
