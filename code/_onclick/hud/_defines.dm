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

//Middle left indicators
#define ui_alienplasmadisplay "14:28,8:13"
#define ui_lingchemdisplay "1,7:15"

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

#define ui_inv1 "6:16,1:5"			//borgs
#define ui_inv2 "7:16,1:5"			//borgs
#define ui_inv3 "8:16,1:5"			//borgs
#define ui_borg_store "9:16,1:5"	//borgs

#define ui_monkey_mask "5:14,1:5"	//monkey
#define ui_monkey_back "6:15,1:5"	//monkey

#define ui_alien_storage_l "6:14,1:5"
#define ui_alien_storage_r "9:18,1:5"

//Lower right, persistant menu
#define ui_drop_throw "14:28,2:7"
#define ui_pull_resist "13:26,2:7"
#define ui_movi "13:26,1:5"
#define ui_acti "12:24,1:5"
#define ui_zonesel "14:28,1:5"
#define ui_acti_alt "14:28,1:5"	//alternative intent switcher for when the interface is hidden (F12)

#define ui_borg_pull "12:24,2:7"
#define ui_borg_module "13:26,2:7"
#define ui_borg_panel "14:28,2:7"

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
#define ui_borg_health "14:28,6:13"		//borgs have the health display where humans have the pressure damage indicator.
#define ui_alien_health "14:28,6:13"	//aliens have the health display where humans have the pressure damage indicator.

//Pop-up inventory
#define ui_shoes "2:8,1:5"

#define ui_iclothing "1:6,2:7"
#define ui_oclothing "2:8,2:7"
#define ui_gloves "3:10,2:7"

#define ui_glasses "1:6,3:9"
#define ui_mask "2:8,3:9"
#define ui_ears "3:10,3:9"

#define ui_head "2:8,4:11"

#define ui_hand "6:14,1:5"
#define ui_hstore1 "5,5"
#define ui_sleep "EAST+1, NORTH-13"
#define ui_rest "EAST+1, NORTH-14"


#define ui_iarrowleft "SOUTH-1,11"
#define ui_iarrowright "SOUTH-1,13"
