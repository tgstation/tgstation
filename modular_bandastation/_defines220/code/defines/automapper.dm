/// Place atom in open space in the middle of the room
#define AREA_SPAWN_MODE_OPEN 0
/// Hug atom next to the wall. Tries not to block things.
#define AREA_SPAWN_MODE_HUG_WALL 1
/// Mount atom to wall. desired_atom MUST have directional helpers.
#define AREA_SPAWN_MODE_MOUNT_WALL 2

#define AREA_SPAWN_MODE_COUNT 3

// "Required map" when we're writing over the centcom map.
#define AUTOMAPPER_MAP_BUILTIN "builtin"
