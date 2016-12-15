// Ghost orbit types:
#define GHOST_ORBIT_CIRCLE   "circle"
#define GHOST_ORBIT_TRIANGLE "triangle"
#define GHOST_ORBIT_HEXAGON  "hexagon"
#define GHOST_ORBIT_SQUARE   "square"
#define GHOST_ORBIT_PENTAGON "pentagon"

// Ghost showing preferences:
#define GHOST_ACCS_NONE 1
#define GHOST_ACCS_DIR  50
#define GHOST_ACCS_FULL 100

#define GHOST_ACCS_NONE_NAME "default sprites"
#define GHOST_ACCS_DIR_NAME  "only directional sprites"
#define GHOST_ACCS_FULL_NAME "full accessories"

#define GHOST_ACCS_DEFAULT_OPTION GHOST_ACCS_FULL

var/global/list/ghost_accs_options = list(GHOST_ACCS_NONE, GHOST_ACCS_DIR, GHOST_ACCS_FULL) // So save files can be sanitized properly.

#define GHOST_OTHERS_SIMPLE         1
#define GHOST_OTHERS_DEFAULT_SPRITE 50
#define GHOST_OTHERS_THEIR_SETTING  100

#define GHOST_OTHERS_SIMPLE_NAME         "white ghost"
#define GHOST_OTHERS_DEFAULT_SPRITE_NAME "default sprites"
#define GHOST_OTHERS_THEIR_SETTING_NAME  "their setting"

#define GHOST_OTHERS_DEFAULT_OPTION GHOST_OTHERS_THEIR_SETTING

var/global/list/ghost_others_options = list(GHOST_OTHERS_SIMPLE, GHOST_OTHERS_DEFAULT_SPRITE, GHOST_OTHERS_THEIR_SETTING) // Same as ghost_accs_options.
