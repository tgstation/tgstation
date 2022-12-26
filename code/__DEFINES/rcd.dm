///A map of which tiles[singluar_name] can be rotated in what directions
///used to create rotated assesst icons & to display ui in rtd
///this is required because initial() returns null when retriving list variables such as tile_rotate_dirs so had to manually type them
GLOBAL_LIST_INIT(tile_rotations, list(
	"edge floor tile" = list(SOUTH, NORTH, EAST, WEST),
	"half floor tile" = list(SOUTH, NORTH),
	"corner floor tile" = list(SOUTH, NORTH, EAST, WEST),
	"edged textured floor tile" = list(SOUTH, NORTH, EAST, WEST),
	"halved textured floor tile" = list(SOUTH, NORTH),
	"cornered textured floor tile" = list(SOUTH, NORTH, EAST, WEST),
	"edged dark floor tile" = list(SOUTH, NORTH, EAST, WEST),
	"halved dark floor tile" = list(SOUTH, NORTH),
	"cornered dark floor tile" = list(SOUTH, NORTH, EAST, WEST),
	"half dark floor tile" = list(SOUTH, NORTH, EAST, WEST, SOUTHEAST, SOUTHWEST, NORTHEAST, NORTHWEST),
	"quarter dark floor tile" = list(SOUTH, NORTH, EAST, WEST),
	"edged dark textured floor tile" = list(SOUTH, NORTH, EAST, WEST),
	"halved dark textured floor tile" = list(SOUTH, NORTH),
	"cornered dark textured floor tile" = list(SOUTH, NORTH, EAST, WEST),
	"edged white floor tile" = list(SOUTH, NORTH, EAST, WEST),
	"cornered white floor tile" = list(SOUTH, NORTH, EAST, WEST),
	"half white floor tile" =  list(SOUTH, NORTH, EAST, WEST, SOUTHEAST, SOUTHWEST, NORTHEAST, NORTHWEST),
	"quarter white floor tile" = list(SOUTH, NORTH, EAST, WEST),
	"edged white textured floor tile" = list(SOUTH, NORTH, EAST, WEST),
	"halved white textured floor tile" = list(SOUTH, NORTH),
	"cornered white textured floor tile" = list(SOUTH, NORTH, EAST, WEST),
	"edged smooth floor tile" = list(SOUTH, NORTH, EAST, WEST),
	"halved smooth floor tile" = list(SOUTH, NORTH),
	"cornered smooth floor tile" = list(SOUTH, NORTH, EAST, WEST),
))
