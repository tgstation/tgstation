// Byond direction defines, because I want to put them somewhere.
// #define NORTH 1
// #define SOUTH 2
// #define EAST 4
// #define WEST 8

/// North direction as a string "[1]"
#define TEXT_NORTH "[NORTH]"
/// South direction as a string "[2]"
#define TEXT_SOUTH "[SOUTH]"
/// East direction as a string "[4]"
#define TEXT_EAST "[EAST]"
/// West direction as a string "[8]"
#define TEXT_WEST "[WEST]"

//dir macros
///Returns true if the dir is diagonal, false otherwise
#define ISDIAGONALDIR(d) (d&(d-1))
///True if the dir is north or south, false therwise
#define NSCOMPONENT(d)   (d&(NORTH|SOUTH))
///True if the dir is east/west, false otherwise
#define EWCOMPONENT(d)   (d&(EAST|WEST))
///Flips the dir for north/south directions
#define NSDIRFLIP(d)     (d^(NORTH|SOUTH))
///Flips the dir for east/west directions
#define EWDIRFLIP(d)     (d^(EAST|WEST))

/// Inverse direction, taking into account UP|DOWN if necessary.
#define REVERSE_DIR(dir) ( ((dir & 85) << 1) | ((dir & 170) >> 1) )

/// Directional offset to place a wall item on the north side of a wall turf.
#define NORTH_DIRECTIONAL_HELPER(path, offset)\
##path/directional/north {\
	dir = NORTH; \
	pixel_y = offset; \
}
/// Directional offset to place a wall item on the south side of a wall turf.
#define SOUTH_DIRECTIONAL_HELPER(path, offset)\
##path/directional/south {\
	dir = SOUTH; \
	pixel_y = -offset; \
}
/// Directional offset to place a wall item on the east side of a wall turf.
#define EAST_DIRECTIONAL_HELPER(path, offset)\
##path/directional/east {\
	dir = EAST; \
	pixel_x = offset; \
}
/// Directional offset to place a wall item on the west side of a wall turf.
#define WEST_DIRECTIONAL_HELPER(path, offset)\
##path/directional/west {\
	dir = WEST; \
	pixel_x = -offset; \
}

/// Create directional subtypes for a path IN ALL CARDINAL DIRECTIONS to simplify mapping.
#define MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS_ALL_CARDINALS(path, offset)\
NORTH_DIRECTIONAL_HELPER(path, offset)\
SOUTH_DIRECTIONAL_HELPER(path, offset)\
EAST_DIRECTIONAL_HELPER(path, offset)\
WEST_DIRECTIONAL_HELPER(path, offset)

/// Create directional subtypes for a path for "visible" directions- as in they aren't meant to display if shown southernly (e.g. posters, signs). Simplifies mapping.
#define MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS_VISIBLE_CARDINALS(path, offset)\
NORTH_DIRECTIONAL_HELPER(path, offset)\
EAST_DIRECTIONAL_HELPER(path, offset)\
WEST_DIRECTIONAL_HELPER(path, offset)
