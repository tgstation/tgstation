// I expect we're going to need quite a few bounds rotation modes by the end of this ~ninjanomnom

///Simple Rotation, swaps bound_width and bound_height and bound_x and bound_y
#define BOUNDS_SIMPLE_ROTATE (1<<0) // Just do a completely regular rotation, nothing fancy

/// Gets the bounds() of the pixel edge of the ref object
#define BOUNDS_EDGE(ref, dir) bounds(ref, (dir & EAST ? ref.bound_width-1 : 0), (dir & NORTH ? ref.bound_height-1 : 0), (dir & (EAST|WEST) ? -(bound_width-1) : 0), (dir & (NORTH|SOUTH) ? -(bound_height-1) : 0))
/// Gets the obounds() of the pixel edge of the ref object
#define OBOUNDS_EDGE(ref, dir) obounds(ref, (dir & EAST ? ref.bound_width-1 : 0), (dir & NORTH ? ref.bound_height-1 : 0), ((dir & (EAST|WEST)) ? -(bound_width-1) : 0), (dir & (NORTH|SOUTH) ? -(bound_height-1) : 0))

/// Gets the appropriate turf to make step_x/y in range 0-31
/// ex: step_y 32 will move the turf up one and change step_y to 0
#define NORMALIZE_STEP(newturf, stepx, stepy) \
	newturf = locate(newturf.x + FLOOR(stepx/world.icon_size, 1), newturf.y + FLOOR(stepy/world.icon_size, 1), newturf.z);\
	stepx = WRAP(stepx, 0, 32);\
	stepy = WRAP(stepy, 0, 32)
