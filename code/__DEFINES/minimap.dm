#define MINIMAP_FLAG_NUCLEAR (1<<0)
#define MINIMAP_FLAG_ALL (1<<5) - 1

///Converts the overworld x and y to minimap x and y values
#define MINIMAP_PIXEL_FROM_WORLD(val) (val*2-3)

//actual size of a users screen in pixels
#define SCREEN_PIXEL_SIZE 480

GLOBAL_LIST_INIT(all_minimap_flags, bitfield2list(MINIMAP_FLAG_ALL))

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

/// Converts an icon pixel coordinate (from ICON_X/ICON_Y modifiers) to a world tile coordinate.
#define MINIMAP_ICON_TO_WORLD(icon_coord, minimap_min) ((minimap_min) + floor(((icon_coord) - 1) / 2))
/// Converts a world tile coordinate to a pixel_w/pixel_z offset for placing a blip on the minimap display.
#define MINIMAP_WORLD_TO_PIXEL(world_coord, minimap_min, half_size) (((world_coord) - (minimap_min)) * 2 + 1 - (half_size))
