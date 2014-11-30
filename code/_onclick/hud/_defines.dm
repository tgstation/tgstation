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

//Upper left action buttons, displayed when you pick up an item that has this enabled.
#define ui_action_slot1 "1:6,14:26"
#define ui_action_slot2 "2:8,14:26"
#define ui_action_slot3 "3:10,14:26"
#define ui_action_slot4 "4:12,14:26"
#define ui_action_slot5 "5:14,14:26"

//Lower left, persistant menu
#define ui_inventory "1:6,1:5"

//Lower center, persistant menu
#define ui_sstore1 "3:10,1:5"
#define ui_id "4:12,1:5"
#define ui_belt "5:14,1:5"
#define ui_back "6:14,1:5"
#define ui_rhand "7:16,1:5"
#define ui_lhand "8:16,1:5"
#define ui_equip "7:16,2:5"
#define ui_swaphand1 "7:16,2:5"
#define ui_swaphand2 "8:16,2:5"
#define ui_storage1 "9:18,1:5"
#define ui_storage2 "10:20,1:5"

#define ui_alien_head "4:12,1:5"	//aliens
#define ui_alien_oclothing "5:14,1:5"	//aliens

#define ui_inv1 "6:16,1:5"			//borgs
#define ui_inv2 "7:16,1:5"			//borgs
#define ui_inv3 "8:16,1:5"			//borgs
#define ui_borg_store "9:16,1:5"	//borgs

#define ui_monkey_uniform "3:14,1:5"//monkey
#define ui_monkey_hat "4:14,1:5"	//monkey
#define ui_monkey_mask "5:14,1:5"	//monkey
#define ui_monkey_back "6:14,1:5"	//monkey

//Lower right, persistant menu
#define ui_dropbutton "11:22,1:5"
#define ui_drop_throw "14:28,2:7"
#define ui_pull_resist "13:26,2:7"
#define ui_acti "13:26,1:5"
#define ui_movi "12:24,1:5"
#define ui_zonesel "14:28,1:5"
#define ui_acti_alt "14:28,1:5" //alternative intent switcher for when the interface is hidden (F12)

#define ui_borg_pull "12:24,2:7"
#define ui_borg_module "13:26,2:7"
#define ui_borg_panel "14:28,2:7"

//Gun buttons
#define ui_gun1 "13:26,3:7"
#define ui_gun2 "14:28, 4:7"
#define ui_gun3 "13:26,4:7"
#define ui_gun_select "14:28,3:7"

//Upper-middle right (damage indicators)
#define ui_toxin "14:28,13:27"
#define ui_fire "14:28,12:25"
#define ui_oxygen "14:28,11:23"
#define ui_pressure "14:28,10:21"

#define ui_alien_toxin "14:28,13:25"
#define ui_alien_fire "14:28,12:25"
#define ui_alien_oxygen "14:28,11:25"

//Middle right (status indicators)
#define ui_nutrition "14:28,5:11"
#define ui_temp "14:28,6:13"
#define ui_health "14:28,7:15"
#define ui_internal "14:28,8:17"
									//borgs
#define ui_borg_health "14:28,6:13" //borgs have the health display where humans have the pressure damage indicator.
#define ui_alien_health "14:28,6:13" //aliens have the health display where humans have the pressure damage indicator.

#define ui_construct_health "15:00,7:15" //same height as humans, hugging the right border
#define ui_construct_purge "15:00,6:15"
#define ui_construct_fire "14:16,8:13" //above health, slightly to the left
#define ui_construct_pull "14:28,2:10" //above the zone_sel icon

#define ui_construct_spell1 "7:16,1:5"
#define ui_construct_spell2 "6:16,1:5"
#define ui_construct_spell3 "8:16,1:5"
#define ui_construct_spell4 "5:16,1:5"
#define ui_construct_spell5 "9:16,1:5"

//Pop-up inventory
#define ui_shoes "2:8,1:5"

#define ui_iclothing "1:6,2:7"
#define ui_oclothing "2:8,2:7"
#define ui_gloves "3:10,2:7"

#define ui_glasses "1:6,3:9"
#define ui_mask "2:8,3:9"
#define ui_ears "3:10,3:9"

#define ui_head "2:8,4:11"

//Intent small buttons
#define ui_help_small "12:8,1:1"
#define ui_disarm_small "12:15,1:18"
#define ui_grab_small "12:32,1:18"
#define ui_harm_small "12:39,1:1"

//#define ui_swapbutton "6:-16,1:5" //Unused

//#define ui_headset "SOUTH,8"
#define ui_hand "6:14,1:5"
#define ui_hstore1 "5,5"
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