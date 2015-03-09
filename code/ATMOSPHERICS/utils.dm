/**
 * Atmospherics-related utilities
 */

// Shapes
#define PIPE_BINARY   0
#define PIPE_STRAIGHT 1 // Like binary, but rotates differently.
#define PIPE_BENT     2
#define PIPE_TRINARY  3
#define PIPE_UNARY    4
#define PIPE_4W       5

// For straight pipes
/proc/rotate_pipe_straight(var/newdir)
	switch(newdir)
		if(SOUTH) // 2->1
			return NORTH
		if(WEST) // 8->4
			return EAST
		// New - N3X
		if(NORTHWEST)
			return NORTH
		if(NORTHEAST)
			return EAST
		if(SOUTHWEST)
			return NORTH
		if(SOUTHEAST)
			return EAST
	return newdir