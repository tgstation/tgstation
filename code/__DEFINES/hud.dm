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

//used to set the default viewport to the user's preference.
#define VIEWPORT_USE_PREF "use_pref"
#define WIDESCREEN_VIEWPORT_SIZE "19x15"
#define SQUARE_VIEWPORT_SIZE "15x15"

// Hud group keys
/// Static elements that are always present in standard hud
#define HUD_GROUP_STATIC 1
/// Inventory elements toggled by the inventory switch
#define HUD_GROUP_TOGGLEABLE_INVENTORY 2
/// Info display HUD elements
#define HUD_GROUP_INFO 3
/// Permanently on-screen elements, regardless of your HUD status
#define HUD_GROUP_SCREEN_OVERLAYS 4
/// Hotkey buttons
#define HUD_GROUP_HOTKEYS 5
/// Open storages and items in them
#define HUD_GROUP_STORAGE 6
/// Total amount of screen groups in use
#define SCREEN_GROUP_AMT 6

// Hud keys for accessing hud objects
#define HUD_MOB_TOGGLE_PALETTE "mob_toggle_palette"
#define HUD_MOB_PALETTE_UP "mob_palette_up"
#define HUD_MOB_PALETTE_DOWN "mob_palette_down"
#define HUD_MOB_SCREENTIP "mob_screentips"
#define HUD_MOB_HEALTH "mob_health"
#define HUD_MOB_LANGUAGE_MENU "mob_language"
#define HUD_MOB_NAVIGATE_MENU "mob_navigate"
#define HUD_MOB_INTENTS "mob_intents"
#define HUD_MOB_MOVE_INTENT "mob_move_intent"
#define HUD_MOB_ZONE_SELECTOR "mob_zonesel"
#define HUD_MOB_PULL "mob_pull"
#define HUD_MOB_DROP "mob_drop"
#define HUD_MOB_THROW "mob_throw"
#define HUD_MOB_HUNGER "mob_hunger"
#define HUD_MOB_STAMINA "mob_stamina"
#define HUD_MOB_SPACESUIT "mob_spacesuit"
#define HUD_MOB_COMBO "mob_combo"
#define HUD_MOB_RESIST "mob_resist"
#define HUD_MOB_REST "mob_rest"
#define HUD_MOB_SLEEP "mob_sleep"
#define HUD_MOB_AREA_CREATOR "mob_area_creator"
#define HUD_MOB_SWAPHAND_1 "mob_swaphand1"
#define HUD_MOB_SWAPHAND_2 "mob_swaphand2"
#define HUD_MOB_CRAFTING_MENU "mob_crafting"
#define HUD_MOB_FLOOR_CHANGER "mob_floor_changer"
#define HUD_MOB_BLOOD_LEVEL "mob_blood_level"
#define HUD_MOB_FOV_BLOCKER "mob_fov_blocker"
#define HUD_MOB_STYLE_METER "mob_style_meter"
#define HUD_MOB_MOOD "mob_mood"
#define HUD_MOB_HEALTHDOLL "mod_healthdoll"

#define HUD_OOZE_NUTRITION_DISPLAY "ooze_nutrition_display"

#define HUD_HUMAN_TOGGLE_INVENTORY "human_toggle_inventory"

#define HUD_NEW_PLAYER_START_NOW "new_player_start_now"
#define HUD_NEW_PLAYER_SIGN_UP "newp_layer_sign_up"
#define HUD_KEY_NEW_PLAYER(slot) "newplayer_hud:[slot]"

#define HUD_SILICON_TAKE_IMAGE "silicon_camera"
#define HUD_SILICON_TABLET "silicon_tablet"
#define HUD_SILICON_ALERTS "silicon_alerts"

#define HUD_CYBORG_LAMP "cyborg_lamp"
#define HUD_CYBORG_HANDS "cyborg_module"
#define HUD_CYBORG_RADIO "cyborg_radio"
#define HUD_CYBORG_DEATH "cyborg_death"
#define HUD_KEY_CYBORG_MODULE(slot) "cyborg_module:[slot]"

#define HUD_AI_FLOOR_INDICATOR "ai_floor_indicator"
#define HUD_AI_GO_UP "ai_go_up"
#define HUD_AI_GO_DOWN "ai_go_down"
#define HUD_AI_AICORE "ai_core"
#define HUD_AI_CAMERA_LIST "ai_camera_list"
#define HUD_AI_CAMERA_TRACK "ai_camera_track"
#define HUD_AI_CAMERA_LIGHT "ai_camera_light"
#define HUD_AI_CREW_MONITOR "ai_crew_monitor"
#define HUD_AI_CREW_MANIFEST "ai_crew_manifest"
#define HUD_AI_ANNOUNCEMENT "ai_announce"
#define HUD_AI_CALL_SHUTTLE "ai_shuttle"
#define HUD_AI_STATE_LAWS "ai_state_laws"
#define HUD_AI_TAKE_IMAGE "ai_take_image"
#define HUD_AI_IMAGE_VIEW "ai_view_image"
#define HUD_AI_SENSORS "ai_sensors"
#define HUD_AI_MULTICAM "ai_view_multicam"
#define HUD_AI_ADD_MULTICAM "ai_add_multicam"

#define HUD_PAI_SOFTWARE "paisoftware"
#define HUD_PAI_SHELL "paishell"
#define HUD_PAI_CHASSIS "paichassis"
#define HUD_PAI_NEWSCASTER "painewscaster"
#define HUD_PAI_HOST_MONITOR "paimonitor"
#define HUD_PAI_GPS "paigps"

#define HUD_GHOST_SPAWNERS "ghost_spawners"
#define HUD_GHOST_ORBIT "ghost_orbit"
#define HUD_GHOST_REENTER_CORPSE "ghost_corpse"
#define HUD_GHOST_TELEPORT "ghost_teleport"
#define HUD_GHOST_PAI "ghost_pai"
#define HUD_GHOST_MINIGAMES "ghost_minigames"
#define HUD_GHOST_DNR "ghost_dnr"
#define HUD_GHOST_SETTINGS "ghost_settings"
#define HUD_KEY_GHOST_HUDBOX(slot) "ghost_hudbox:[slot]"

#define HUD_ALIEN_QUEEN_FINDER "alien_queen_finder"
#define HUD_ALIEN_PLASMA_DISPLAY "alien_plasma_display"
#define HUD_ALIEN_HUNTER_LEAP "alien_hunter_leap"

#define HUD_BLOB_POWER_DISPLAY "blob_power_display"
#define HUD_BLOB_JUMP_TO_CORE "blob_jump_to_core"
#define HUD_BLOB_JUMP_TO_NODE "blob_jump_to_node"
#define HUD_BLOB_BLOBBERNAUT "blob_blobbernaut"
#define HUD_BLOB_RESOURCES "blob_resources"
#define HUD_BLOB_NODE "blob_node"
#define HUD_BLOB_FACTORY "blob_factory"
#define HUD_BLOB_READAPT "blob_readapt"
#define HUD_BLOB_RELOCATE "blob_relocate"

#define HUD_BLOBBERNAUT_OVERMIND "blobbernaut_overmind"

#define HUD_GUARDIAN_MANIFEST "guardian_manifest"
#define HUD_GUARDIAN_RECALL "guardian_recall"
#define HUD_GUARDIAN_LIGHT "guardian_light"
#define HUD_GUARDIAN_COMMUNICATE "guardian_communicate"
#define HUD_GUARDIAN_TOGGLE "guardian_toggle"

#define HUD_VOIDWALKER_SPACE_CAMO "voidwalker_space_camo"
#define HUD_VOIDWALKER_VOID_JUMP "voidwalker_void_jump"

#define HUD_CHANGELING_CHEMS "changeling_chems"
#define HUD_CHANGELING_STING "changeling_sting"

#define HUD_CULTIST_ARROW "cultist_arrow"

#define HUD_HERETIC_ARROW "heretic_arrow"
#define HUD_HERETIC_MOON_HEALTH "heretic_moon_health"

#define HUD_WIZARD_COMPACT_PERKS "wizard_compact_perks"
#define HUD_WIZARD_PERK(slot) "wizard_perk:[slot]"

/// Converts item slots to hud keys as a compiler constant
#define HUD_KEY_ITEM_SLOT(slot) "item_slot:" + #slot
/// Hand2hudkey
#define HUD_KEY_HAND_SLOT(slot) "hand_slot:[slot]"

#define HUD_MULTITOOL_ARROW "multitool_arrow"

#define HUD_XENOBIO_CONSOLE "xenobio_console"

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
#define ui_alienplasmadisplay_human "EAST,CENTER-4:15"

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
#define ui_ghost_dnr "SOUTH:6,CENTER:24"
#define ui_ghost_teleport "SOUTH:6,CENTER+1:24"
#define ui_ghost_settings "SOUTH: 6, CENTER+2:24"
#define ui_ghost_minigames "SOUTH: 6, CENTER+3:24"
#define ui_ghost_language_menu "SOUTH: 6, CENTER+4:22"
#define ui_ghost_floor_changer "SOUTH: 6, CENTER+4:7"

//Voidwalker
#define ui_voidwalker_left_of_hands "CENTER+-2:16,SOUTH+0:5"

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
