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

/**
 * values based on old hand ui positions (CENTER:-/+16,SOUTH:5)
 * If item arg is set, its base_pixel_x and base_pixel_y will be added to the pixel offsets of the return value.
 */
/proc/ui_hand_position(index, obj/item/item)
	var/x_off = -(!(index % 2))
	var/y_off = round((index-1) / 2)
	var/x_px_off = 16
	var/y_px_off = 5
	if(item)
		x_px_off += item.base_pixel_x
		y_px_off += item.base_pixel_y
	return"CENTER+[x_off]:[x_px_off],SOUTH+[y_off]:[y_px_off]"

/proc/ui_equip_position(mob/M)
	var/y_off = round((M.held_items.len-1) / 2) //values based on old equip ui position (CENTER: +/-16,SOUTH+1:5)
	return "CENTER:-16,SOUTH+[y_off+1]:5"

/proc/ui_swaphand_position(mob/M, which = 1) //values based on old swaphand ui positions (CENTER: +/-16,SOUTH+1:5)
	var/x_off = which == 1 ? -1 : 0
	var/y_off = round((M.held_items.len-1) / 2)
	return "CENTER+[x_off]:16,SOUTH+[y_off+1]:5"

//Lower left, persistent menu
#define ui_inventory "WEST:6,SOUTH:5"

//Middle left indicators
#define ui_lingchemdisplay "WEST,CENTER-1:15"
#define ui_lingstingdisplay "WEST:6,CENTER-3:11"

//Lower center, persistent menu
#define ui_sstore1 "CENTER-5:10,SOUTH:5"
#define ui_id(x_px, y_px) "CENTER-4:[12+x_px],SOUTH:[5+y_px]"
#define ui_belt(x_px, y_px) "CENTER-3:[14+x_px],SOUTH:[5+y_px]"
#define ui_back(x_px, y_px) "CENTER-2:[14+x_px],SOUTH:[5+y_px]"
#define ui_storage1(x_px, y_px) "CENTER+1:[18+x_px],SOUTH:[5+y_px]"
#define ui_storage2(x_px, y_px) "CENTER+2:[20+x_px],SOUTH:[5+y_px]"
#define ui_combo "CENTER+4:24,SOUTH+1:7" //combo meter for martial arts

//Lower right, persistent menu
#define ui_drop_throw "EAST-1:28,SOUTH+1:7"
#define ui_above_movement "EAST-2:26,SOUTH+1:7"
#define ui_above_intent "EAST-3:24, SOUTH+1:7"
#define ui_movi "EAST-2:26,SOUTH:5"
#define ui_acti "EAST-3:24,SOUTH:5"
#define ui_combat_toggle "EAST-3:24,SOUTH:5"
#define ui_zonesel "EAST-1:28,SOUTH:5"
#define ui_acti_alt "EAST-1:28,SOUTH:5" //alternative intent switcher for when the interface is hidden (F12)
#define ui_crafting "EAST-4:22,SOUTH:5"
#define ui_building "EAST-4:22,SOUTH:21"
#define ui_language_menu "EAST-4:6,SOUTH:21"
#define ui_skill_menu "EAST-4:22,SOUTH:5"

//Upper-middle right (alerts)
#define ui_alert1 "EAST-1:28,CENTER+5:27"
#define ui_alert2 "EAST-1:28,CENTER+4:25"
#define ui_alert3 "EAST-1:28,CENTER+3:23"
#define ui_alert4 "EAST-1:28,CENTER+2:21"
#define ui_alert5 "EAST-1:28,CENTER+1:19"

//Middle right (status indicators)
#define ui_healthdoll "EAST-1:28,CENTER-2:13"
#define ui_health "EAST-1:28,CENTER-1:15"
#define ui_internal "EAST-1:28,CENTER+1:17"
#define ui_mood "EAST-1:28,CENTER:17"
#define ui_spacesuit "EAST-1:28,CENTER-4:10"
#define ui_stamina "EAST-1:28,CENTER-3:10"

//Pop-up inventory
#define ui_shoes(x_px, y_px) "WEST+1:[8+x_px],SOUTH:[5+y_px]"
#define ui_iclothing(x_px, y_px) "WEST:[6+x_px],SOUTH+1:[7+y_px]"
#define ui_oclothing(x_px, y_px) "WEST+1:[8+x_px],SOUTH+1:[7+y_px]"
#define ui_gloves(x_px, y_px) "WEST+2:[10+x_px],SOUTH+1:[7+y_px]"
#define ui_glasses(x_px, y_px) "WEST:[6+x_px],SOUTH+3:[11+y_px]"
#define ui_mask(x_px, y_px) "WEST+1:[8+x_px],SOUTH+2:[9+y_px]"
#define ui_ears(x_px, y_px) "WEST+2:[10+x_px],SOUTH+2:[9+y_px]"
#define ui_neck(x_px, y_px) "WEST:[6+x_px],SOUTH+2:[9+y_px]"
#define ui_head(x_px, y_px) "WEST+1:[8+x_px],SOUTH+3:[11+y_px]"

//Generic living
#define ui_living_pull "EAST-1:28,CENTER-3:15"
#define ui_living_healthdoll "EAST-1:28,CENTER-1:15"

//Drones
#define ui_drone_drop "CENTER+1:18,SOUTH:5"
#define ui_drone_pull "CENTER+2:2,SOUTH:5"
#define ui_drone_storage(x_px, y_px) "CENTER-2:[14+x_px],SOUTH:[5+y_px]"
#define ui_drone_head(x_px, y_px) "CENTER-3:[14+x_px],SOUTH:[5+y_px]"

//Cyborgs
#define ui_borg_health "EAST-1:28,CENTER-1:15"
#define ui_borg_pull "EAST-2:26,SOUTH+1:7"
#define ui_borg_radio "EAST-1:28,SOUTH+1:7"
#define ui_borg_intents "EAST-2:26,SOUTH:5"
#define ui_borg_lamp "CENTER-3:16, SOUTH:5"
#define ui_borg_tablet "CENTER-4:16, SOUTH:5"
#define ui_inv1(x_px, y_px) "CENTER-2:[16+y_px],SOUTH:[5+y_px]"
#define ui_inv2(x_px, y_px) "CENTER-1:[16+y_px],SOUTH:[5+y_px]"
#define ui_inv3(x_px, y_px) "CENTER:[16+y_px],SOUTH:[5+y_px]"
#define ui_borg_module "CENTER+1:16,SOUTH:5"
#define ui_borg_store "CENTER+2:16,SOUTH:5"
#define ui_borg_camera "CENTER+3:21,SOUTH:5"
#define ui_borg_alerts "CENTER+4:21,SOUTH:5"
#define ui_borg_language_menu "CENTER+4:19,SOUTH+1:6"

//Aliens
#define ui_alien_health "EAST,CENTER-1:15"
#define ui_alienplasmadisplay "EAST,CENTER-2:15"
#define ui_alien_queen_finder "EAST,CENTER-3:15"
#define ui_alien_storage_r "CENTER+1:18,SOUTH:5"
#define ui_alien_language_menu "EAST-4:20,SOUTH:5"

//AI
#define ui_ai_core "SOUTH:6,WEST"
#define ui_ai_camera_list "SOUTH:6,WEST+1"
#define ui_ai_track_with_camera "SOUTH:6,WEST+2"
#define ui_ai_camera_light "SOUTH:6,WEST+3"
#define ui_ai_crew_monitor "SOUTH:6,WEST+4"
#define ui_ai_crew_manifest "SOUTH:6,WEST+5"
#define ui_ai_alerts "SOUTH:6,WEST+6"
#define ui_ai_announcement "SOUTH:6,WEST+7"
#define ui_ai_shuttle "SOUTH:6,WEST+8"
#define ui_ai_state_laws "SOUTH:6,WEST+9"
#define ui_ai_pda_send "SOUTH:6,WEST+10"
#define ui_ai_pda_log "SOUTH:6,WEST+11"
#define ui_ai_take_picture "SOUTH:6,WEST+12"
#define ui_ai_view_images "SOUTH:6,WEST+13"
#define ui_ai_sensor "SOUTH:6,WEST+14"
#define ui_ai_multicam "SOUTH+1:6,WEST+13"
#define ui_ai_add_multicam "SOUTH+1:6,WEST+14"
#define ui_ai_language_menu "SOUTH+1:8,WEST+11:30"

//pAI
#define ui_pai_software "SOUTH:6,WEST"
#define ui_pai_shell "SOUTH:6,WEST+1"
#define ui_pai_chassis "SOUTH:6,WEST+2"
#define ui_pai_rest "SOUTH:6,WEST+3"
#define ui_pai_light "SOUTH:6,WEST+4"
#define ui_pai_newscaster "SOUTH:6,WEST+5"
#define ui_pai_host_monitor "SOUTH:6,WEST+6"
#define ui_pai_crew_manifest "SOUTH:6,WEST+7"
#define ui_pai_state_laws "SOUTH:6,WEST+8"
#define ui_pai_pda_send "SOUTH:6,WEST+9"
#define ui_pai_pda_log "SOUTH:6,WEST+10"
#define ui_pai_internal_gps "SOUTH:6,WEST+11"
#define ui_pai_take_picture "SOUTH:6,WEST+12"
#define ui_pai_view_images "SOUTH:6,WEST+13"
#define ui_pai_radio "SOUTH:6,WEST+14"
#define ui_pai_language_menu "SOUTH+1:8,WEST+13:31"

//Ghosts
#define ui_ghost_spawners_menu "SOUTH:6,CENTER-3:24"
#define ui_ghost_orbit "SOUTH:6,CENTER-2:24"
#define ui_ghost_reenter_corpse "SOUTH:6,CENTER-1:24"
#define ui_ghost_teleport "SOUTH:6,CENTER:24"
#define ui_ghost_pai "SOUTH: 6, CENTER+1:24"
#define ui_ghost_minigames "SOUTH: 6, CENTER+2:24"
#define ui_ghost_language_menu "SOUTH: 22, CENTER+3:8"

//Blobbernauts
#define ui_blobbernaut_overmind_health "EAST-1:28,CENTER+0:19"

//Families
#define ui_wanted_lvl "NORTH,11"
