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

#define MAPPING_DIRECTIONAL_HELPERS(path, offset) \
##path/directional/north {\
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

#define MAPPING_DIRECTIONAL_HELPERS_EMPTY(path) \
##path/directional/north {\
	dir = NORTH; \
} \
##path/directional/south {\
	dir = SOUTH; \
} \
##path/directional/east {\
	dir = EAST; \
} \
##path/directional/west {\
	dir = WEST; \
}

#define BUTTON_DIRECTIONAL_HELPERS(path) \
##path/table { \
	on_table = TRUE; \
	icon_state = parent_type::icon_state + "_table"; \
	base_icon_state = parent_type::icon_state + "_table"; \
} \
WALL_MOUNT_DIRECTIONAL_HELPERS(path)
