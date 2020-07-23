// I expect we're going to need quite a few bounds rotation modes by the end of this ~ninjanomnom

#define BOUNDS_SIMPLE_ROTATE (1<<0) // Just do a completely regular rotation, nothing fancy

/// Gets the bounds() of the pixel edge of the ref object
#define BOUNDS_EDGE(ref, dir) bounds(ref, (dir & EAST ? ref.bound_width-1 : 0), (dir & NORTH ? ref.bound_height-1 : 0), (dir & (EAST|WEST) ? -(bound_width-1) : 0), (dir & (NORTH|SOUTH) ? -(bound_height-1) : 0))
#define OBOUNDS_EDGE(ref, dir) obounds(ref, (dir & EAST ? ref.bound_width-1 : 0), (dir & NORTH ? ref.bound_height-1 : 0), ((dir & (EAST|WEST)) ? -(bound_width-1) : 0), (dir & (NORTH|SOUTH) ? -(bound_height-1) : 0))
