/// Save objects types
#define SAVE_OBJECTS (1 << 1)
/// Save objects variables from obj.get_save_vars() and obj.get_custom_save_vars()
#define SAVE_OBJECTS_VARIABLES (1 << 2)
/// Save objects custom properties from obj.on_object_saved()
#define SAVE_OBJECTS_PROPERTIES (1 << 3)
/// Save mobs types (excludes mob/living/carbon)
#define SAVE_MOBS (1 << 4)
/// Save turfs types, if disabled, this will save turfs as /turf/template_noop
#define SAVE_TURFS (1 << 5)
/// Save turfs atmospheric properties (gases, temperature, etc.)
#define SAVE_TURFS_ATMOS (1 << 6)
/// Save space turfs, if disabled, this will replace objects, mobs, and areas that are on space turfs with /template_noop
#define SAVE_TURFS_SPACE (1 << 7)
/// Save areas types, if disabled, this will save areas as /area/template_noop
#define SAVE_AREAS (1 << 8)
/// Save areas types for default shuttles like arrivals, cargo, mining, whiteship, etc. (does not include custom shuttles), if disabled, uses /template_noop
#define SAVE_AREAS_DEFAULT_SHUTTLES (1 << 9)
/// Save areas types for custom shuttles that players make, if disabled, uses /template_noop
#define SAVE_AREAS_CUSTOM_SHUTTLES (1 << 10)

//Ignore turf if it contains
#define SAVE_SHUTTLEAREA_DONTCARE 0
#define SAVE_SHUTTLES_ONLY 1

#define DMM2TGM_MESSAGE "MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE"
