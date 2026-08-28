///Converts the overworld x and y to minimap x and y values
#define MINIMAP_PIXEL_FROM_WORLD(val) (val*2-3)

//actual size of a users screen in pixels
#define SCREEN_PIXEL_SIZE 480

//Drawing tool colors
#define TACMAP_DRAWING_RED "#ff0000"
#define TACMAP_DRAWING_YELLOW "#FFFF00"
#define TACMAP_DRAWING_PURPLE "#A020F0"
#define TACMAP_DRAWING_BLUE "#0000FF"


//Turf colours
#define TACMAP_BLACK "#111111d0"
#define TACMAP_SOLID "#ebe5e5ee"
#define TACMAP_DOOR "#451e5eee"
#define TACMAP_WINDOW "#525252d0"
#define TACMAP_FENCE "#8c2294ee"
#define TACMAP_LAVA "#db4206d0"
#define TACMAP_DIRT "#9c906dd0"
#define TACMAP_SHALE "#706955d0"
#define TACMAP_SNOW "#c4e3e9d0"
#define TACMAP_MARS_DIRT "#aa5f44d0"
#define TACMAP_ICE "#93cae0d0"
#define TACMAP_WATER "#94b0d59c" //lower opacity as its really bright

//Area colours
//Departments
#define TACMAP_AREA_COMMAND COLOR_COMMAND_BLUE
#define TACMAP_AREA_CARGO COLOR_CARGO_BROWN
#define TACMAP_AREA_ENGINEERING COLOR_ENGINEERING_ORANGE
#define TACMAP_AREA_MEDICAL COLOR_MEDICAL_BLUE
#define TACMAP_AREA_SCIENCE COLOR_SCIENCE_PINK
#define TACMAP_AREA_SECURITY COLOR_SECURITY_RED
#define TACMAP_AREA_SERVICE COLOR_SERVICE_LIME
//General
#define TACMAP_AREA_MAINTENANCE COLOR_WEBSAFE_DARK_GRAY

/// How much we multiply the drawn image by, and as a result the pixel coordinates
#define MINIMAP_PIXEL_MULTIPLIER 2
/// Converts an icon pixel coordinate (from ICON_X/ICON_Y modifiers) to a world tile coordinate.
#define MINIMAP_ICON_TO_WORLD(icon_coord, minimap_min) ((minimap_min) + floor(((icon_coord) - 1) / MINIMAP_PIXEL_MULTIPLIER))
/// Converts a world tile coordinate to a pixel_w/pixel_z offset for placing a blip on the minimap display.
#define MINIMAP_WORLD_TO_PIXEL(world_coord, minimap_min, half_size) (((world_coord) - (minimap_min)) * MINIMAP_PIXEL_MULTIPLIER + 1 - (half_size))
#define COMSIG_MINIMAP_ADD(blip_tag) "minimap_add_" + blip_tag
#define COMSIG_MINIMAP_REMOVE(blip_tag) "minimap_remove_" + blip_tag
// sends a index of how much to change by
#define COMSIG_MINIMAP_CHANGE_Z_LEVEL "minimap_z_change"
#define COMSIG_MINIMAP_ACTION_TRIGGER "minimap_action_trigger"
	#define COMSIG_MINIMAP_ACTION_TRIGGER_CANCEL (1<<0)


#define MINIMAP_BOMB_BLIP "nuke"
#define MINIMAP_NUKEDISK_BLIP "nuke_disk"
#define MINIMAP_NUKEOP_BLIP "nukeop"
#define MINIMAP_NUKEOP_BORG_BLIP "nukeop_borg"
#define MINIMAP_SYNDICATE_MECH_BLIP "syndicate_mech"
#define MINIMAP_SYNDIE_TURRET_BLIP "syndie_turret"
#define MINIMAP_LADDER_BLIP "ladder"
#define MINIMAP_STAIR_BLIP "stair"
#define MINIMAP_ANNOTATION_TAG_NUCLEAR "nuclear_ops"
