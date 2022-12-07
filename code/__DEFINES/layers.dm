//Defines for atom layers and planes
//KEEP THESE IN A NICE ACSCENDING ORDER, PLEASE
//Reminder to everyone that planes override layers: things on the same plane will sort in order of layers

//NEVER HAVE ANYTHING BELOW THIS PLANE ADJUST IF YOU NEED MORE SPACE
#define LOWEST_EVER_PLANE -100

#define CLICKCATCHER_PLANE -80

#define PLANE_SPACE -25
#define PLANE_SPACE_PARALLAX -20

#define GRAVITY_PULSE_PLANE -19
#define GRAVITY_PULSE_RENDER_TARGET "*GRAVPULSE_RENDER_TARGET"

#define RENDER_PLANE_TRANSPARENT -18 //Transparent plane that shows openspace underneath the floor

#define FLOOR_PLANE -10
#define FLOOR_PLANE_RENDER_TARGET "*FLOOR_PLANE"
#define OVER_TILE_PLANE -9
#define GAME_PLANE -8
#define HIDDEN_WALL_PLANE -7
#define UNDER_FRILL_PLANE -6
#define UNDER_FRILL_RENDER_TARGET "*UNDER_FRILL_PLANE"
#define FRILL_PLANE -5
#define FRILL_MASK_PLANE -4
#define FRILL_MASK_RENDER_TARGET "*FRILL_MASK_PLANE"
#define OVER_FRILL_PLANE -3

///Slightly above the game plane but does not catch mouse clicks. Useful for certain visuals that should be clicked through, like seethrough trees
#define SEETHROUGH_PLANE -2

#define RENDER_PLANE_GAME_WORLD -1

#define BLACKNESS_PLANE 0 //To keep from conflicts with SEE_BLACKNESS internals

#define AREA_PLANE 2
#define MASSIVE_OBJ_PLANE 3
#define GHOST_PLANE 4
#define POINT_PLANE 5


//---------- LIGHTING -------------
///Normal 1 per turf dynamic lighting underlays
#define LIGHTING_PLANE 10

///Lighting objects that are "free floating"
#define O_LIGHTING_VISUAL_PLANE 11
#define O_LIGHTING_VISUAL_RENDER_TARGET "O_LIGHT_VISUAL_PLANE"

/// This plane masks out lighting to create an "emissive" effect, ie for glowing lights in otherwise dark areas.
#define EMISSIVE_PLANE 14

#define RENDER_PLANE_LIGHTING 15

///Things that should render ignoring lighting
#define ABOVE_LIGHTING_PLANE 16

///---------------- MISC -----------------------

///Pipecrawling images
#define PIPECRAWL_IMAGES_PLANE 20

///AI Camera Static
#define CAMERA_STATIC_PLANE 21

///Anything that wants to be part of the game plane, but also wants to draw above literally everything else
#define HIGH_GAME_PLANE 22

#define FULLSCREEN_PLANE 23

///--------------- FULLSCREEN RUNECHAT BUBBLES ------------

///Popup Chat Messages
#define RUNECHAT_PLANE 30
/// Plane for balloon text (text that fades up)
#define BALLOON_CHAT_PLANE 31

//-------------------- HUD ---------------------
//HUD layer defines
#define HUD_PLANE 40
#define ABOVE_HUD_PLANE 41

///Plane of the "splash" icon used that shows on the lobby screen. only render plate planes should be above this
#define SPLASHSCREEN_PLANE 50

//-------------------- Rendering ---------------------
#define RENDER_PLANE_GAME 100
#define RENDER_PLANE_NON_GAME 101
#define RENDER_PLANE_MASTER 102

// Lummox I swear to god I will find you
// NOTE! You can only ever have planes greater then -10000, if you add too many with large offsets you will brick multiz
// Same can be said for large multiz maps. Tread carefully mappers
#define HIGHEST_EVER_PLANE RENDER_PLANE_MASTER
/// The range unique planes can be in
#define PLANE_RANGE (HIGHEST_EVER_PLANE - LOWEST_EVER_PLANE)

// PLANE_SPACE layer(s)
#define SPACE_LAYER 1.8

//#define TURF_LAYER 2 //For easy recordkeeping; this is a byond define. Most floors (FLOOR_PLANE) and walls (GAME_PLANE) use this.

//(Hopefully, double check this wallening todo) OVER_TILE_PLANE layers
#define CULT_OVERLAY_LAYER 2.01
#define MID_TURF_LAYER 2.02
#define HIGH_TURF_LAYER 2.03
#define TURF_PLATING_DECAL_LAYER 2.031
#define TURF_DECAL_LAYER 2.039 //Makes turf decals appear in DM how they will look inworld.
#define ABOVE_OPEN_TURF_LAYER 2.04
#define CLOSED_TURF_LAYER 2.05
#define BULLET_HOLE_LAYER 2.06
#define ABOVE_NORMAL_TURF_LAYER 2.08
#define LATTICE_LAYER 2.2
#define DISPOSAL_PIPE_LAYER 2.3
#define GAS_PIPE_HIDDEN_LAYER 2.35 //layer = initial(layer) + piping_layer / 1000 in atmospherics/update_icon() to determine order of pipe overlap
#define WIRE_LAYER 2.4
#define TRAM_XING_LAYER 2.41
#define TRAM_RAIL_LAYER 2.42
#define TRAM_FLOOR_LAYER 2.43
#define WIRE_BRIDGE_LAYER 2.44
#define WIRE_TERMINAL_LAYER 2.45
#define GAS_SCRUBBER_LAYER 2.46
#define GAS_PIPE_VISIBLE_LAYER 2.47 //layer = initial(layer) + piping_layer / 1000 in atmospherics/update_icon() to determine order of pipe overlap
#define GAS_FILTER_LAYER 2.48
#define GAS_PUMP_LAYER 2.49
#define PLUMBING_PIPE_VISIBILE_LAYER 2.495//layer = initial(layer) + ducting_layer / 3333 in atmospherics/handle_layer() to determine order of duct overlap
#define BOT_PATH_LAYER 2.497
#define LOW_OBJ_LAYER 2.5
///catwalk overlay of /turf/open/floor/plating/catwalk_floor
#define CATWALK_LAYER 2.51
#define LOW_SIGIL_LAYER 2.52
#define SIGIL_LAYER 2.53
#define HIGH_PIPE_LAYER 2.54
// Anything aboe this layer is not "on" a turf for the purposes of washing
// I hate this life of ours
#define FLOOR_CLEAN_LAYER 2.55

//GAME_PLANE layers

//Walls draw below
//We draw them to the game plane so we can take advantage of SIDE_MAP for em
//Need to cover for the whole "things below us" with position offsetting with pixel_y/z rather just one or the other
#define UNDER_WALL_LAYER 2.66
#define WALL_LAYER 2.67
#define ABOVE_WALL_LAYER 2.68
#define WALL_CLICKCATCH_LAYER 2.69
#define ON_WALL_LAYER 2.7

#define BELOW_OPEN_DOOR_LAYER 2.75
#define BLASTDOOR_LAYER 2.78
#define OPEN_DOOR_LAYER 2.8
#define DOOR_ACCESS_HELPER_LAYER 2.83 //keep this above OPEN_DOOR_LAYER, special layer used for /obj/effect/mapping_helpers/airlock/access
#define DOOR_HELPER_LAYER 2.85 //keep this above DOOR_ACCESS_HELPER_LAYER and OPEN_DOOR_LAYER since the others tend to have tiny sprites that tend to be covered up.
#define PROJECTILE_HIT_THRESHHOLD_LAYER 2.88 //projectiles won't hit objects at or below this layer if possible
#define TABLE_LAYER 2.9
#define GATEWAY_UNDERLAY_LAYER 2.93
#define BELOW_OBJ_LAYER 2.95
#define LOW_ITEM_LAYER 2.98
//#define OBJ_LAYER 3 //For easy recordkeeping; this is a byond define
#define CLOSED_DOOR_LAYER 3.55
#define CLOSED_FIREDOOR_LAYER 3.58
#define ABOVE_OBJ_LAYER 3.6
#define CLOSED_BLASTDOOR_LAYER 3.63 // ABOVE WINDOWS AND DOORS
#define SHUTTER_LAYER 3.65 // HERE BE DRAGONS
#define ABOVE_WINDOW_LAYER 3.68
#define SIGN_LAYER 3.7
#define CORGI_ASS_PIN_LAYER 3.73
#define NOT_HIGH_OBJ_LAYER 3.75
#define HIGH_OBJ_LAYER 3.78
#define BELOW_MOB_LAYER 3.8

#define LOW_MOB_LAYER 3.83
#define LYING_MOB_LAYER 3.88
#define VEHICLE_LAYER 3.9
#define MOB_BELOW_PIGGYBACK_LAYER 3.94
//#define MOB_LAYER 4 //For easy recordkeeping; this is a byond define
#define MOB_SHIELD_LAYER 4.01
#define MOB_ABOVE_PIGGYBACK_LAYER 4.06
#define MOB_UPPER_LAYER 4.07
#define HITSCAN_PROJECTILE_LAYER 4.09
#define ABOVE_MOB_LAYER 4.1
#define WALL_OBJ_LAYER 4.25
#define EDGED_TURF_LAYER 4.3
#define ON_EDGED_TURF_LAYER 4.35
#define SPACEVINE_LAYER 4.4
#define LARGE_MOB_LAYER 4.5
#define SPACEVINE_MOB_LAYER 4.6
#define ABOVE_ALL_MOB_LAYER 4.7
//#define FLY_LAYER 5 //For easy recordkeeping; this is a byond define
#define HIGH_BUBBLE_LAYER 5.03
#define GASFIRE_LAYER 5.05
#define RIPPLE_LAYER 5.1

//---------- LIGHTING -------------

#define LIGHTING_PRIMARY_LAYER 15	//The layer for the main lights of the station
#define LIGHTING_PRIMARY_DIMMER_LAYER 15.1	//The layer that dims the main lights of the station
#define LIGHTING_SECONDARY_LAYER 16	//The colourful, usually small lights that go on top




//---------- EMISSIVES -------------
//Layering order of these is not particularly meaningful.
//Important part is the seperation of the planes for control via plane_master

/// The render target used by the emissive layer.
#define EMISSIVE_RENDER_TARGET "*EMISSIVE_PLANE"
/// The layer you should use if you _really_ don't want an emissive overlay to be blocked.
#define EMISSIVE_LAYER_UNBLOCKABLE 9999

///--------------- FULLSCREEN IMAGES ------------

#define FLASH_LAYER 1
#define FULLSCREEN_LAYER 2
#define UI_DAMAGE_LAYER 3
#define BLIND_LAYER 4
#define CRIT_LAYER 5
#define CURSE_LAYER 6
#define ECHO_LAYER 7

#define BLIND_EFFECTS_LAYER 100

///--------------- FULLSCREEN RUNECHAT BUBBLES ------------
/// Bubble for typing indicators
#define TYPING_LAYER 500

#define RADIAL_BACKGROUND_LAYER 0
///1000 is an unimportant number, it's just to normalize copied layers
#define RADIAL_CONTENT_LAYER 1000

#define ADMIN_POPUP_LAYER 1

///Layer for screentips
#define SCREENTIP_LAYER 4


#define LOBBY_BACKGROUND_LAYER 3
#define LOBBY_BUTTON_LAYER 4

///cinematics are "below" the splash screen
#define CINEMATIC_LAYER -1

///Plane master controller keys
#define PLANE_MASTERS_GAME "plane_masters_game"
#define PLANE_MASTERS_COLORBLIND "plane_masters_colorblind"

//Plane master critical flags
//Describes how different plane masters behave when they are being culled for performance reasons
/// This plane master will not go away if its layer is culled. useful for preserving effects
#define PLANE_CRITICAL_DISPLAY (1<<0)
/// This plane master will temporarially remove relays to non critical planes if it's layer is culled (and it's critical)
/// This is VERY hacky, but needed to ensure that some instances of BLEND_MULITPLY work as expected (fuck you god damn parallax)
/// It also implies that the critical plane has a *'d render target, making it mask itself
#define PLANE_CRITICAL_NO_EMPTY_RELAY (1<<1)

#define PLANE_CRITICAL_FUCKO_PARALLAX (PLANE_CRITICAL_DISPLAY|PLANE_CRITICAL_NO_EMPTY_RELAY)

/// A value of /datum/preference/numeric/multiz_performance that disables the option
#define MULTIZ_PERFORMANCE_DISABLE -1
/// We expect at most 3 layers of multiz
/// Increment this define if you make a huge map. We unit test for it too just to make it easy for you
/// If you modify this, you'll need to modify the tsx file too
#define MAX_EXPECTED_Z_DEPTH 2
