///each cell in a spatial_grid is this many turfs in length and width
#define SPATIAL_GRID_CELLSIZE 15
#define INVERSE_SPATIAL_GRID_CELLSIZE (1 / SPATIAL_GRID_CELLSIZE)

#define SPATIAL_GRID_CHANNELS 2

//grid contents channels

///everything that is hearing sensitive is stored in this channel
#define SPATIAL_GRID_CONTENTS_TYPE_HEARING RECURSIVE_CONTENTS_HEARING_SENSITIVE
///every movable that has a client in it is stored in this channel
#define SPATIAL_GRID_CONTENTS_TYPE_CLIENTS RECURSIVE_CONTENTS_CLIENT_MOBS
