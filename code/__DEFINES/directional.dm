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

/// Inverse direction, taking into account UP|DOWN if necessary.
#define REVERSE_DIR(dir) ( ((dir & 85) << 1) | ((dir & 170) >> 1) )

// Wallening todo: temporary helper, until we finish fleshing things out and can convert the main one
// Why are we not just changing the sprites agian?
#define INVERT_MAPPING_DIRECTIONAL_HELPERS(path, offset) \
##path/directional/north {\
	dir = SOUTH; \
	MAP_SWITCH(pixel_z, pixel_y) = offset; \
} \
##path/directional/south {\
	dir = NORTH; \
	MAP_SWITCH(pixel_z, pixel_y) = -offset; \
} \
##path/directional/east {\
	dir = WEST; \
	pixel_x = offset; \
} \
##path/directional/west {\
	dir = EAST; \
	pixel_x = -offset; \
}

/// Directional helpers for things that use the wall_mount element
#define WALL_MOUNT_DIRECTIONAL_HELPERS(path) \
##path/directional/north {\
	dir = SOUTH; \
	MAP_SWITCH(pixel_z, pixel_y) = 35; \
} \
##path/directional/south {\
	dir = NORTH; \
	MAP_SWITCH(pixel_z, pixel_y) = -8; \
} \
##path/directional/east {\
	dir = WEST; \
	pixel_x = 11; \
	MAP_SWITCH(pixel_z, pixel_y) = 16; \
} \
##path/directional/west {\
	dir = EAST; \
	pixel_x = -11; \
	MAP_SWITCH(pixel_z, pixel_y) = 16; \
}

/// Create directional subtypes for a path to simplify mapping.

#define MAPPING_DIRECTIONAL_HELPERS(path, offset) ##path/directional/north {\
	dir = NORTH; \
	MAP_SWITCH(pixel_z, pixel_y) = offset; \
} \
##path/directional/south {\
	dir = SOUTH; \
	MAP_SWITCH(pixel_z, pixel_y) = -offset; \
} \
##path/directional/east {\
	dir = EAST; \
	pixel_x = offset; \
} \
##path/directional/west {\
	dir = WEST; \
	pixel_x = -offset; \
}
