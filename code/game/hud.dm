
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

#define ui_monkey_mask "5:14,1:5"	//monkey
#define ui_monkey_back "6:14,1:5"	//monkey

//Lower right, persistant menu
#define ui_drop_throw "14:28,2:7"
#define ui_pull_resist "13:26,2:7"
#define ui_acti "13:26,1:5"
#define ui_movi "12:24,1:5"
#define ui_zonesel "14:28,1:5"
#define ui_acti_alt "14:28,1:5" //alternative intent switcher for when the interface is hidden (F12)

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
#define ui_borg_health "14:28,6:13" //borgs have the health display where humans have the pressure damage indicator.
#define ui_alien_health "14:28,6:13" //aliens have the health display where humans have the pressure damage indicator.


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




obj/hud/New(var/type = 0)
	instantiate(type)
	..()
	return


/obj/hud/proc/hidden_inventory_update()
	if(!mymob) return
	if(inventory_shown && hud_shown)
		if(ishuman(mymob))
			if(mymob:shoes) mymob:shoes:screen_loc = ui_shoes
			if(mymob:gloves) mymob:gloves:screen_loc = ui_gloves
			if(mymob:ears) mymob:ears:screen_loc = ui_ears
			if(mymob:glasses) mymob:glasses:screen_loc = ui_glasses
			if(mymob:w_uniform) mymob:w_uniform:screen_loc = ui_iclothing
			if(mymob:wear_suit) mymob:wear_suit:screen_loc = ui_oclothing
			if(mymob:wear_mask) mymob:wear_mask:screen_loc = ui_mask
			if(mymob:head) mymob:head:screen_loc = ui_head
	else
		if(ishuman(mymob))
			if(mymob:shoes) mymob:shoes:screen_loc = null
			if(mymob:gloves) mymob:gloves:screen_loc = null
			if(mymob:ears) mymob:ears:screen_loc = null
			if(mymob:glasses) mymob:glasses:screen_loc = null
			if(mymob:w_uniform) mymob:w_uniform:screen_loc = null
			if(mymob:wear_suit) mymob:wear_suit:screen_loc = null
			if(mymob:wear_mask) mymob:wear_mask:screen_loc = null
			if(mymob:head) mymob:head:screen_loc = null

/obj/hud/proc/persistant_inventory_update()
	if(!mymob) return
	if(hud_shown)
		if(ishuman(mymob))
			if(mymob:s_store) mymob:s_store:screen_loc = ui_sstore1
			if(mymob:wear_id) mymob:wear_id:screen_loc = ui_id
			if(mymob:belt) mymob:belt:screen_loc = ui_belt
			if(mymob:back) mymob:back:screen_loc = ui_back
			if(mymob:l_store) mymob:l_store:screen_loc = ui_storage1
			if(mymob:r_store) mymob:r_store:screen_loc = ui_storage2
	else
		if(ishuman(mymob))
			if(mymob:s_store) mymob:s_store:screen_loc = null
			if(mymob:wear_id) mymob:wear_id:screen_loc = null
			if(mymob:belt) mymob:belt:screen_loc = null
			if(mymob:back) mymob:back:screen_loc = null
			if(mymob:l_store) mymob:l_store:screen_loc = null
			if(mymob:r_store) mymob:r_store:screen_loc = null


/obj/hud
	var/obj/screen/action_intent
	var/obj/screen/move_intent
	var/hud_shown = 1	//Used for the HUD toggle (F12)
	var/inventory_shown = 1	//the inventory

/obj/hud/proc/instantiate(var/type = 0)

	mymob = loc
	if(!istype(mymob, /mob)) return 0

	if(ishuman(mymob))
		human_hud(mymob.UI) // Pass the player the UI style chosen in preferences

		spawn()
			if((RADAR in mymob.augmentations) && mymob.radar_open)
				mymob:start_radar()
			else if(RADAR in mymob.augmentations)
				mymob:place_radar_closed()

	else if(ismonkey(mymob))
		monkey_hud(mymob.UI)

	else if(isbrain(mymob))
		brain_hud(mymob.UI)

	else if(islarva(mymob))
		larva_hud()

	else if(isalien(mymob))
		alien_hud()

	else if(isAI(mymob))
		ai_hud()

	else if(isrobot(mymob))
		robot_hud()

//	else if(ishivebot(mymob))
//		hivebot_hud()

//	else if(ishivemainframe(mymob))
//		hive_mainframe_hud()

	else if(isobserver(mymob))
		ghost_hud()

	return
