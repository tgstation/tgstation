// Z level of the overmap
#define OVERMAP_Z_LEVEL 1 // aka centcom z

// size of the overmap (OVERMAP_SIZE x OVERMAP_SIZE)
#define OVERMAP_SIZE 15 // keep this odd to provide a centre tile

// These overmap coords are configured to place it in the top left of the z level
#define OVERMAP_LEFT_SIDE_COORD 1
#define OVERMAP_RIGHT_SIDE_COORD OVERMAP_SIZE

#define OVERMAP_NORTH_SIDE_COORD (world.maxy)
#define OVERMAP_SOUTH_SIDE_COORD OVERMAP_NORTH_SIDE_COORD - (OVERMAP_SIZE - 1)
