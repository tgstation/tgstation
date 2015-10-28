/*
	These defines specificy screen locations.  For more information, see the byond documentation on the screen_loc var.

	The short version:

	Everything is encoded as strings because apparently that's how Byond rolls.

	"1,1" is the bottom left square of the user's screen.  This aligns perfectly with the turf grid.
	"1:2,3:4" is the square (1,3) with pixel offsets (+2, +4); slightly right and slightly above the turf grid.
	Pixel offsets are used so you don't perfectly hide the turf under them, that would be crappy.

	The size of the user's screen is defined by client.view (indirectly by world.view), in our case "15x15".
	Therefore, the top right corner (except during admin shenanigans) is at "15,15"
*/

//Overlays that cover the entire screen
#define ui_entire_screen "WEST,SOUTH TO EAST,NORTH"

//Upper left action buttons, displayed when you pick up an item that has this enabled.
#define ui_action_slot1 "WEST:6,NORTH-1:26"
#define ui_action_slot2 "WEST+1:8,NORTH-1:26"
#define ui_action_slot3 "WEST+2:10,NORTH-1:26"
#define ui_action_slot4 "WEST+3:12,NORTH-1:26"
#define ui_action_slot5 "WEST+4:14,NORTH-1:26"

//Lower left, persistant menu
#define ui_inventory "WEST:6,SOUTH:5"

//Lower center, persistant menu
#define ui_sstore1 "WEST+2:10,SOUTH:5"
#define ui_id "WEST+3:12,SOUTH:5"
#define ui_belt "WEST+4:14,SOUTH:5"
#define ui_back "CENTER-2:14,SOUTH:5"
#define ui_rhand "CENTER-1:16,SOUTH:5"
#define ui_lhand "CENTER:16,SOUTH:5"
#define ui_equip "CENTER-1:16,SOUTH+1:5"
#define ui_swaphand1 "CENTER-1:16,SOUTH+1:5"
#define ui_swaphand2 "CENTER:16,SOUTH+1:5"
#define ui_storage1 "CENTER+1:18,SOUTH:5"
#define ui_storage2 "CENTER+2:20,SOUTH:5"

#define ui_alien_head "WEST+3:12,SOUTH:5"	//aliens
#define ui_alien_oclothing "WEST+4:14,SOUTH:5"	//aliens

#define ui_borg_sight "CENTER-3:16,SOUTH:5"	//borgs
#define ui_inv1 "CENTER-2:16,SOUTH:5"			//borgs
#define ui_inv2 "CENTER-1:16,SOUTH:5"			//borgs
#define ui_inv3 "CENTER:16,SOUTH:5"			//borgs
#define ui_borg_module "CENTER+1:16,SOUTH:5" //borgs
#define ui_borg_store "CENTER+2:16,SOUTH:5"	//borgs
#define ui_mommi_store "CENTER+1:16,SOUTH:5"
#define ui_mommi_module "CENTER:16,SOUTH:5"
#define ui_mommi_sight "CENTER-2:16,SOUTH:5"
#define ui_mommi_hats "CENTER-3:16,SOUTH:5"

#define ui_monkey_uniform "WEST+2:14,SOUTH:5"//monkey
#define ui_monkey_hat "WEST+3:14,SOUTH:5"	//monkey
#define ui_monkey_glasses "WEST+1:14,SOUTH:5"	//monkey
#define ui_monkey_mask "WEST+4:14,SOUTH:5"	//monkey
#define ui_monkey_back "WEST+5:14,SOUTH:5"	//monkey

//Lower right, persistant menu
#define ui_dropbutton "EAST-4:22,SOUTH:5"
#define ui_drop_throw "EAST-1:28,SOUTH+1:7"
#define ui_pull_resist "EAST-2:26,SOUTH+1:7"
#define ui_acti "EAST-2:26,SOUTH:5"
#define ui_movi "EAST-3:24,SOUTH:5"
#define ui_zonesel "EAST-1:28,SOUTH:5"
#define ui_acti_alt "EAST-1:28,SOUTH:5" //alternative intent switcher for when the interface is hidden (F12)

#define ui_borg_pull "EAST-3:24,SOUTH+1:7"
//#define ui_borg_module "13:26,2:7"
#define ui_borg_panel "EAST-1:28,SOUTH+1:7"

//Gun buttons
#define ui_gun1 "EAST-2:26,SOUTH+2:7"
#define ui_gun2 "EAST-1:28, SOUTH+3:7"
#define ui_gun3 "EAST-2:26,SOUTH+3:7"
#define ui_gun_select "EAST-1:28,SOUTH+2:7"

//Upper-middle right (damage indicators)
#define ui_toxin "EAST-1:28,NORTH-2:27"
#define ui_fire "EAST-1:28,NORTH-3:25"
#define ui_oxygen "EAST-1:28,NORTH-4:23"
#define ui_pressure "EAST-1:28,NORTH-5:21"

#define ui_alien_toxin "EAST-1:28,NORTH-2:25"
#define ui_alien_fire "EAST-1:28,NORTH-3:25"
#define ui_alien_oxygen "EAST-1:28,NORTH-4:25"

//Middle right (status indicators)
#define ui_nutrition "EAST-1:28,CENTER-2:11"
#define ui_temp "EAST-1:28,CENTER-1:13"
#define ui_health "EAST-1:28,CENTER:15"
#define ui_internal "EAST-1:28,CENTER+1:17"
									//borgs
#define ui_borg_health "EAST-1:28,CENTER-1:13" //borgs have the health display where humans have the pressure damage indicator.
#define ui_alien_health "EAST-1:28,CENTER-1:13" //aliens have the health display where humans have the pressure damage indicator.

#define ui_construct_health "EAST:00,CENTER:15" //same height as humans, hugging the right border
#define ui_construct_purge "EAST:00,CENTER-1:15"
#define ui_construct_fire "EAST-1:16,CENTER+1:13" //above health, slightly to the left
#define ui_construct_pull "EAST-1:28,SOUTH+1:10" //above the zone_sel icon

#define ui_spell_master "14:16,14:16"
#define ui_genetic_master "14:16,12:16"

//Pop-up inventory
#define ui_shoes "WEST+1:8,SOUTH:5"

#define ui_iclothing "WEST:6,SOUTH+1:7"
#define ui_oclothing "WEST+1:8,SOUTH+1:7"
#define ui_gloves "WEST+2:10,SOUTH+1:7"

#define ui_glasses "WEST:6,SOUTH+2:9"
#define ui_mask "WEST+1:8,SOUTH+2:9"
#define ui_ears "WEST+2:10,SOUTH+2:9"

#define ui_head "WEST+1:8,SOUTH+3:11"

//Intent small buttons
#define ui_help_small "EAST+3:8,SOUTH:1"
#define ui_disarm_small "EAST+3:15,SOUTH:18"
#define ui_grab_small "EAST+3:32,SOUTH:18"
#define ui_harm_small "EAST+3:39,SOUTH:1"

//#define ui_swapbutton "6:-16,1:5" //Unused

//#define ui_headset "SOUTH,8"
#define ui_hand "CENTER-1:14,SOUTH:5"
#define ui_hstore1 "CENTER-2,CENTER-2"
//#define ui_resist "EAST+1,SOUTH-1"
#define ui_sleep "EAST+1, NORTH-13"
#define ui_rest "EAST+1, NORTH-14"


#define ui_iarrowleft "SOUTH-1,11"
#define ui_iarrowright "SOUTH-1,13"

// AI (Ported straight from /tg/)

#define ui_ai_core "SOUTH:6,WEST:16"
#define ui_ai_camera_list "SOUTH:6,WEST+1:16"
#define ui_ai_track_with_camera "SOUTH:6,WEST+2:16"
#define ui_ai_camera_light "SOUTH:6,WEST+3:16"
//#define ui_ai_crew_monitor "SOUTH:6,WEST+4:16"
#define ui_ai_crew_manifest "SOUTH:6,WEST+4:16"
#define ui_ai_alerts "SOUTH:6,WEST+5:16"
#define ui_ai_announcement "SOUTH:6,WEST+6:16"
#define ui_ai_shuttle "SOUTH:6,WEST+7:16"
#define ui_ai_state_laws "SOUTH:6,WEST+8:16"
#define ui_ai_pda_send "SOUTH:6,WEST+9:16"
#define ui_ai_pda_log "SOUTH:6,WEST+10:16"
#define ui_ai_take_picture "SOUTH:6,WEST+11:16"
#define ui_ai_view_images "SOUTH:6,WEST+12:16"

//Adminbus HUD
#define ui_adminbus_bg "1:0,1:0"
#define ui_adminbus_delete "11:31,1:6"
#define ui_adminbus_delmobs "1:6,5:14"
#define ui_adminbus_spclowns "1:8,6:14"
#define ui_adminbus_spcarps "1:8,7:10"
#define ui_adminbus_spbears "1:8,8:6"
#define ui_adminbus_sptrees "1:8,9:2"
#define ui_adminbus_spspiders "1:8,9:30"
#define ui_adminbus_spalien "1:5,10:26"
#define ui_adminbus_loadsids "5:0,2:9"
#define ui_adminbus_loadsmone "5:0,3:5"
#define ui_adminbus_massrepair "6:3,2:9"
#define ui_adminbus_massrejuv "6:3,3:5"
#define ui_adminbus_hook "10:0,3:7"
#define ui_adminbus_juke "11:11,3:7"
#define ui_adminbus_tele "12:22,3:7"
#define ui_adminbus_bumpers_1 "9:21,2:14"
#define ui_adminbus_bumpers_2 "10:5,2:14"
#define ui_adminbus_bumpers_3 "10:21,2:14"
#define ui_adminbus_door_0 "11:11,2:14"
#define ui_adminbus_door_1 "11:27,2:14"
#define ui_adminbus_roadlights_0 "12:17,2:14"
#define ui_adminbus_roadlights_1 "13:1,2:14"
#define ui_adminbus_roadlights_2 "13:17,2:14"
#define ui_adminbus_free "13:9,14:20"
#define ui_adminbus_home "14:6,14:20"
#define ui_adminbus_antag "15:3,14:20"
#define ui_adminbus_dellasers "6:13,13:26"
#define ui_adminbus_givelasers "6:29,13:26"
#define ui_adminbus_delbombs "9:18,13:26"
#define ui_adminbus_givebombs "10:2,13:26"
#define ui_adminbus_tdred "1:18,13:26"
#define ui_adminbus_tdarena "2:4,13:26"
#define ui_adminbus_tdgreen "3:6,13:26"
#define ui_adminbus_tdobs "2:4,14:28"