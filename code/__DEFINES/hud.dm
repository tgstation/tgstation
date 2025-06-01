//HUD styles.  Index order defines how they are cycled in F12.
/// Standard hud
#define HUD_STYLE_STANDARD 1
/// Reduced hud (just hands and intent switcher)
#define HUD_STYLE_REDUCED 2
/// No hud (for screenshots)
#define HUD_STYLE_NOHUD 3

/// Used in show_hud(); Please ensure this is the same as the maximum index.
#define HUD_VERSIONS 3

// Consider these images/atoms as part of the UI/HUD (apart of the appearance_flags)
/// Used for progress bars and chat messages
#define APPEARANCE_UI_IGNORE_ALPHA (RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR|RESET_ALPHA|PIXEL_SCALE)
/// Used for HUD objects
#define APPEARANCE_UI (RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR|PIXEL_SCALE)

/*
	These defines specificy screen locations.  For more information, see the byond documentation on the screen_loc var.

	The short version:

	Everything is encoded as strings because apparently that's how Byond rolls.

	"1,1" is the bottom left square of the user's screen.  This aligns perfectly with the turf grid.
	"1:2,3:4" is the square (1,3) with pixel offsets (+2, +4); slightly right and slightly above the turf grid.
	Pixel offsets are used so you don't perfectly hide the turf under them, that would be crappy.

	In addition, the keywords NORTH, SOUTH, EAST, WEST and CENTER can be used to represent their respective
	screen borders. NORTH-1, for example, is the row just below the upper edge. Useful if you want your
	UI to scale with screen size.

	The size of the user's screen is defined by client.view (indirectly by world.view), in our case "15x15".
	Therefore, the top right corner (except during admin shenanigans) is at "15,15"
*/

// Middle
#define around_player "CENTER-1,CENTER-1"

//Lower left, persistent menu
#define ui_inventory "WEST:6,SOUTH:5"

//Middle left indicators
#define ui_lingchemdisplay "WEST,CENTER-1:15"
#define ui_lingstingdisplay "WEST:6,CENTER-3:11"
#define ui_blooddisplay "WEST:6,CENTER:-2"
#define ui_xenobiodisplay "WEST:6,CENTER:-4"

//Lower center, persistent menu
#define ui_sstore1 "CENTER-5:10,SOUTH:5"
#define ui_id "CENTER-4:12,SOUTH:5"
#define ui_belt "CENTER-3:14,SOUTH:5"
#define ui_back "CENTER-2:14,SOUTH:5"
#define ui_storage1 "CENTER+1:18,SOUTH:5"
#define ui_storage2 "CENTER+2:20,SOUTH:5"
#define ui_combo "CENTER+4:24,SOUTH+1:7" //combo meter for martial arts

//Lower right, persistent menu
#define ui_rest "EAST-1:28,SOUTH+1:7"
#define ui_drop_throw "EAST-1:28,SOUTH+1:24"
#define ui_above_throw "EAST-1:28,SOUTH+1:41"
#define ui_above_movement "EAST-2:26,SOUTH+1:7"
#define ui_above_movement_top "EAST-2:26, SOUTH+1:24"
#define ui_above_intent "EAST-3:24, SOUTH+1:7"
#define ui_movi "EAST-2:26,SOUTH:5"
#define ui_acti "EAST-3:24,SOUTH:5"
#define ui_combat_toggle "EAST-3:24,SOUTH:5"
#define ui_zonesel "EAST-1:28,SOUTH:5"
#define ui_acti_alt "EAST-1:28,SOUTH:5" //alternative intent switcher for when the interface is hidden (F12)
#define ui_crafting "EAST-4:22,SOUTH:5"
#define ui_building "EAST-4:22,SOUTH:21"
#define ui_language_menu "EAST-4:6,SOUTH:21"
#define ui_navigate_menu "EAST-4:6,SOUTH:5"

//Upper left (action buttons)
#define ui_action_palette "WEST+0:23,NORTH-1:5"
#define ui_action_palette_offset(north_offset) ("WEST+0:23,NORTH-[1+north_offset]:5")

#define ui_palette_scroll "WEST+1:8,NORTH-6:28"
#define ui_palette_scroll_offset(north_offset) ("WEST+1:8,NORTH-[6+north_offset]:28")

//Middle right (status indicators)
#define ui_healthdoll "EAST-1:28,CENTER-2:17"
#define ui_health "EAST-1:28,CENTER-1:19"
#define ui_internal "EAST-1:28,CENTER+1:21"
#define ui_mood "EAST-1:28,CENTER:21"
#define ui_hunger "EAST-1:2,CENTER:21"
#define ui_spacesuit "EAST-1:28,CENTER-4:14"
#define ui_stamina "EAST-1:28,CENTER-3:14"

//Pop-up inventory
#define ui_shoes "WEST+1:8,SOUTH:5"
#define ui_iclothing "WEST:6,SOUTH+1:7"
#define ui_oclothing "WEST+1:8,SOUTH+1:7"
#define ui_gloves "WEST+2:10,SOUTH+1:7"
#define ui_glasses "WEST:6,SOUTH+3:11"
#define ui_mask "WEST+1:8,SOUTH+2:9"
#define ui_ears "WEST+2:10,SOUTH+2:9"
#define ui_neck "WEST:6,SOUTH+2:9"
#define ui_head "WEST+1:8,SOUTH+3:11"

//Generic living
#define ui_living_pull "EAST-1:28,CENTER-3:15"
#define ui_living_healthdoll "EAST-1:28,CENTER-1:15"

//Humans
#define ui_human_floor_changer "EAST-4:22,SOUTH:5"
#define ui_human_crafting "EAST-3:24,SOUTH+1:7"
#define ui_human_navigate "EAST-3:7,SOUTH+1:7"
#define ui_human_language "EAST-3:7,SOUTH+1:24"
#define ui_human_area "EAST-3:24,SOUTH+1:24"

//Drones
#define ui_drone_drop "CENTER+1:18,SOUTH:5"
#define ui_drone_pull "CENTER+1.5:2,SOUTH:5"
#define ui_drone_storage "CENTER-2:14,SOUTH:5"
#define ui_drone_head "CENTER-3:14,SOUTH:5"

//Cyborgs
#define ui_borg_health "EAST-1:28,CENTER-1:15"
#define ui_borg_pull "EAST-2:26,SOUTH+1:7"
#define ui_borg_radio "EAST-1:28,SOUTH+1:7"
#define ui_borg_intents "EAST-2:26,SOUTH:5"
#define ui_borg_lamp "CENTER-3:16, SOUTH:5"
#define ui_borg_tablet "CENTER-4:16, SOUTH:5"
#define ui_inv1 "CENTER-2:16,SOUTH:5"
#define ui_inv2 "CENTER-1 :16,SOUTH:5"
#define ui_inv3 "CENTER :16,SOUTH:5"
#define ui_borg_module "CENTER+1:16,SOUTH:5"
#define ui_borg_store "CENTER+2:16,SOUTH:5"
#define ui_borg_camera "CENTER+3:21,SOUTH:5"
#define ui_borg_alerts "CENTER+4:21,SOUTH:5"
#define ui_borg_language_menu "CENTER+4:19,SOUTH+1:6"
#define ui_borg_navigate_menu "CENTER+4:3,SOUTH+1:6"
#define ui_borg_floor_changer "EAST-1:28,SOUTH+1:39"

//Aliens
#define ui_alien_health "EAST,CENTER-1:15"
#define ui_alienplasmadisplay "EAST,CENTER-2:15"
#define ui_alien_queen_finder "EAST,CENTER-3:15"
#define ui_alien_storage_r "CENTER+1:18,SOUTH:5"
#define ui_alien_language_menu "EAST-4:20,SOUTH:5"
#define ui_alien_navigate_menu "EAST-4:4,SOUTH:5"
#define ui_alien_floor_change "EAST-3:24, SOUTH:24"

//AI
#define ui_ai_core "BOTTOM:6,RIGHT-4"
#define ui_ai_shuttle "BOTTOM:6,RIGHT-3"
#define ui_ai_announcement "BOTTOM:6,RIGHT-2"
#define ui_ai_state_laws "BOTTOM:6,RIGHT-1"
#define ui_ai_mod_int "BOTTOM:6,RIGHT"
#define ui_ai_language_menu "BOTTOM+1:8,RIGHT-1:30"

#define ui_ai_crew_monitor "BOTTOM:6,CENTER-1"
#define ui_ai_crew_manifest "BOTTOM:6,CENTER"
#define ui_ai_alerts "BOTTOM:6,CENTER+1"

#define ui_ai_view_images "BOTTOM:6,LEFT+4"
#define ui_ai_camera_list "BOTTOM:6,LEFT+3"
#define ui_ai_track_with_camera "BOTTOM:6,LEFT+2"
#define ui_ai_camera_light "BOTTOM:6,LEFT+1"
#define ui_ai_sensor "BOTTOM:6,LEFT"
#define ui_ai_multicam "BOTTOM+1:6,LEFT+1"
#define ui_ai_add_multicam "BOTTOM+1:6,LEFT"
#define ui_ai_take_picture "BOTTOM+2:6,LEFT"
#define ui_ai_floor_indicator "BOTTOM+5,RIGHT"
#define ui_ai_godownup "BOTTOM+5,RIGHT-1"

//pAI
#define ui_pai_software "SOUTH:6,WEST"
#define ui_pai_shell "SOUTH:6,WEST+1"
#define ui_pai_chassis "SOUTH:6,WEST+2"
#define ui_pai_rest "SOUTH:6,WEST+3"
#define ui_pai_light "SOUTH:6,WEST+4"
#define ui_pai_state_laws "SOUTH:6,WEST+5"
#define ui_pai_crew_manifest "SOUTH:6,WEST+6"
#define ui_pai_host_monitor "SOUTH:6,WEST+7"
#define ui_pai_internal_gps "SOUTH:6,WEST+8"
#define ui_pai_mod_int "SOUTH:6,WEST+9"
#define ui_pai_newscaster "SOUTH:6,WEST+10"
#define ui_pai_take_picture "SOUTH:6,WEST+11"
#define ui_pai_view_images "SOUTH:6,WEST+12"
#define ui_pai_radio "SOUTH:6,WEST+13"
#define ui_pai_language_menu "SOUTH+1:8,WEST+12:31"
#define ui_pai_navigate_menu "SOUTH+1:8,WEST+12:15"

//Ghosts
#define ui_ghost_spawners_menu "SOUTH:6,CENTER-3:24"
#define ui_ghost_orbit "SOUTH:6,CENTER-2:24"
#define ui_ghost_reenter_corpse "SOUTH:6,CENTER-1:24"
#define ui_ghost_teleport "SOUTH:6,CENTER:24"
#define ui_ghost_settings "SOUTH: 6, CENTER+1:24"
#define ui_ghost_minigames "SOUTH: 6, CENTER+2:24"
#define ui_ghost_language_menu "SOUTH: 6, CENTER+3:24"
#define ui_ghost_floor_changer "SOUTH: 6, CENTER+3:8"

//Blobbernauts
#define ui_blobbernaut_overmind_health "EAST-1:28,CENTER+0:19"

// Defines relating to action button positions

/// Whatever the base action datum thinks is best
#define SCRN_OBJ_DEFAULT "default"
/// Floating somewhere on the hud, not in any predefined place
#define SCRN_OBJ_FLOATING "floating"
/// In the list of buttons stored at the top of the screen
#define SCRN_OBJ_IN_LIST "list"
/// In the collapseable palette
#define SCRN_OBJ_IN_PALETTE "palette"
///Inserted first in the list
#define SCRN_OBJ_INSERT_FIRST "first"

// Plane group keys, used to group swaths of plane masters that need to appear in subwindows
/// The primary group, holds everything on the main window
#define PLANE_GROUP_MAIN "main"
/// A secondary group, used when a client views a generic window
#define PLANE_GROUP_POPUP_WINDOW(screen) "popup-[REF(screen)]"

/// The filter name for the hover outline
#define HOVER_OUTLINE_FILTER "hover_outline"
