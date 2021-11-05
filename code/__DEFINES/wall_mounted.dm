/// Create directional subtypes for a path to simplify mapping.
#define MAPPING_DIRECTIONAL_HELPERS(path, offset) ##path/directional/north {\
	dir = SOUTH; \
	pixel_y = offset; \
} \
##path/directional/south {\
	dir = NORTH; \
	pixel_y = -offset; \
} \
##path/directional/east {\
	dir = WEST; \
	pixel_x = offset; \
} \
##path/directional/west; {\
	dir = EAST; \
	pixel_x = -offset; \
}

#define MAPPING_DIRECTIONAL_HELPERS_INVERSE(path, offset) ##path/directional/north {\
	dir = NORTH; \
	pixel_y = offset; \
} \
##path/directional/south {\
	dir = SOUTH; \
	pixel_y = -offset; \
} \
##path/directional/east {\
	dir = EAST; \
	pixel_x = offset; \
} \
##path/directional/west {\
	dir = WEST; \
	pixel_x = -offset; \
}
