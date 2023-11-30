/// Use this to set the base and ACTUAL pixel offsets of an object at the same time
/// You should always use this for pixel setting in typepaths, unless you want the map display to look different from in game
#define SET_BASE_PIXEL(x, y) \
	pixel_x = x; \
	base_pixel_x = x; \
	pixel_y = y; \
	base_pixel_y = y;

/// Helper define, sets JUST base pixel offsets
#define _SET_BASE_PIXEL_NO_OFFSET(x, y) \
	base_pixel_x = x; \
	base_pixel_y = y;

#define SET_BASE_VISUAL_PIXEL(w, z) \
	pixel_w = w; \
	base_pixel_w = w; \
	pixel_z = z; \
	base_pixel_z = z;

#define _SET_BASE_PIXEL_VISUAL_NO_OFFSET(w, z) \
	base_pixel_z = w; \
	base_pixel_z = z;

/// Much like [SET_BASE_PIXEL], except it will not effect pixel offsets in mapping programs
#define SET_BASE_PIXEL_NOMAP(x, y) MAP_SWITCH(SET_BASE_PIXEL(x, y), _SET_BASE_PIXEL_NO_OFFSET(x, y))
