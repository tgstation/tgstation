// Contains values for the layer var for everything, to cut down on magic numbers and needing to remember what everything is
// Please keep everything in order!

#define MAP_LAYER 9001 // Stuff for mappers like landmarks and shit. This high so they can always see it.

#define CINEMATIC_LAYER 25 // nuke explosions, anything else we want to be over everything.

#define EQUIPMENT_LAYER 20.5
#define UI_LAYER 20

#define EYE_LAYER 19 // things "on your eye" like blindness, the red screen so real, flashes, the welding mask overlay, etc

#define ABSTRACT_LAYER 18 // things between lighting and the UI like the arrow that appears when you point at things

#define LIGHTING_LAYER 15

#define GHOST_LAYER 10

#define TALL_LAYER 9 // things that are taller than a tile and need to be above everything else

#define SPECIAL_EFFECT_LAYER 8 // smoke, explosion particles, gasses, fire etc

#define ON_TOP_OF_MOB_LAYER 7.6
#define MOB_LAYER 7.5 // overrides the byond default
#define BLOB_LAYER 7.4
#define BOT_LAYER 7.3
#define DOOR_CLOSED_LAYER 7.01

#define ITEM_LAYER 4 // all obj/item, I'm too lazy to put them on specific layers

#define DOOR_OPEN_LAYER 3.99
#define MECH_LAYER 3.7
#define MACHINE_LAYER 3.5 // most obj/machinery
#define TURRET_UP_LAYER 3.46
#define TURRET_COVER_LAYER 3.45
#define TURRET_DOWN_LAYER 3.44
#define STRUCTURE_LAYER 3.2 // structures that aren't tables or below the floor
#define ON_WALL_LAYER 3.15
// most stuff on the wall is low priority and should be below basically everything because you probably don't want to click on-wall stuff
// still need to make a lot of stuff use this define, as of this writing I only made a couple of things use it
// it would be great from a utility standpoint if these were below tables but it would look super goofy
#define TABLE_LAYER 3.1
#define UNDER_TABLE_LAYER 3.09
#define GLOWSHROOM_LAYER 3.05 // up this high because some are wall mounted
#define ATMOSPHERIC_MACHINE_LAYER 3.04 // vents, scrubbers, etc

#define WALL_LAYER 3 // shared by windows
#define GRILLE_LAYER 2.999

#define FOAM_LAYER 2.9
#define ALIEN_WEED_LAYER 2.71
#define VINE_LAYER 2.7
#define RUNE_LAYER 2.61
#define GRAFFITI_LAYER 2.6
#define BLOOD_LAYER 2.51
#define DIRT_LAYER 2.5
#define CONVEYOR_LAYER 2.1
#define ON_TOP_OF_TILE_LAYER 2.001

#define TILE_LAYER 2 // floor tiles

#define BEHIND_TILE_LAYER 1.999 // currently used by that backpack you can hide under the floor
#define PIPE_LAYER 1.8
#define TERMINAL_LAYER 1.71
#define CABLE_LAYER 1.7
#define DISPOSAL_LAYER 1.6
#define BEACON_LAYER 1.5

#define PLATING_LAYER 1

#define LATTICE_LAYER 0.9
#define SPACE_EFFECT_LAYER 0.2
#define SPACE_LAYER 0.1
#define BEHIND_SPACE_LAYER 0.001 // just don't think about it too hard ok
#define MAPPING_FAR_BACK_LAYER 0.001
// special mapping layer for turfs so everything appears above them when mapping
// gets reset to normal as part of New()


#define SLIGHTLY_ABOVE 0.00001 // Don't use any differences in layer smaller than this.
// Used like obj.layer = layer + SLIGHTLY_ABOVE to make obj appear directly above src