

//Lower left, persistant menu
#define ui_inventory "1:6,1:5"


//Inventory close areas. When you pass your mouse over these areas they close the inventory.
#define ui_invclosearea1 "1,1 to 1:6,5"
#define ui_invclosearea2 "1,1 to 4,1:16"
#define ui_invclosearea3 "4:16,1 to 5:16,5"
#define ui_invclosearea4 "1,5:16 to 4,5:16"


//Lower center, persistant menu
#define ui_sstore1 "3:10,1:5"
#define ui_id "4:12,1:5"
#define ui_belt "5:14,1:5"
#define ui_back "6:14,1:5"
#define ui_rhand "7:16,1:5"
#define ui_lhand "8:16,1:5"
#define ui_swaphand1 "7:16,2:5"
#define ui_swaphand2 "8:16,2:5"
#define ui_storage1 "9:18,1:5"
#define ui_storage2 "10:20,1:5"

#define ui_alien_head "4:12,1:5"	//aliens
#define ui_alien_oclothing "5:14,1:5"	//aliens

#define ui_inv1 "6:16,1:5"			//borgs
#define ui_inv2 "7:16,1:5"			//borgs
#define ui_inv3 "8:16,1:5"			//borgs
#define ui_borg_store "9:14,1:5"	//borgs

#define ui_monkey_mask "5:14,1:5"	//monkey
#define ui_monkey_back "6:14,1:5"	//monkey

//Lower right, persistant menu
#define ui_dropbutton "13:26,1:5"
#define ui_throw "13:26,1:5"
#define ui_pull "13:26,2:7"
#define ui_acti "12:24,1:5"

#define ui_movi "13:26,2:7"
#define ui_zonesel "14:28,1:5"

//Gun buttons
#define ui_gun1 "11:22,2:7"
#define ui_gun2 "10:20,2:7"
#define ui_gun3 "9:18,2:7"
#define ui_gun_select "11:22,1:5"

//Middle right (damage indicators)
#define ui_pressure "14:28,6:13"
#define ui_oxygen "14:28,7:15"
#define ui_fire "14:28,8:17"
#define ui_toxin "14:28,9:19"

//Upper-middle right (damage indicators)
#define ui_toxin "14:28,13:27"
#define ui_fire "14:28,12:25"
#define ui_oxygen "14:28,11:23"
#define ui_pressure "14:28,10:21"

//Middle right (status indicators)
#define ui_nutrition "14:28,5:11"
#define ui_temp "14:28,6:13"
#define ui_health "14:28,7:15"
#define ui_internal "14:28,8:17"

									//borgs
#define ui_borg_health "14:28,6:13" //borgs have the health display where humans have the pressure damage indicator.
#define ui_alien_health "14:28,6:13" //aliens have the health display where humans have the pressure damage indicator.
#define ui_throw_old "13:26,2:7"
#define ui_movi_old "12:24,2:7"
#define ui_pull_old "14:28,2:7"

//Pop-up inventory
#define ui_shoes "2:8,1:5"

#define ui_iclothing "1:6,2:7"
#define ui_oclothing "2:8,2:7"
#define ui_gloves "3:10,2:7"

#define ui_glasses "1:6,3:9"
#define ui_mask "2:8,3:9"
#define ui_lear "3:10,3:9"
#define ui_rear "3:10,4:11"

#define ui_head "2:8,4:11"




//Intent small buttons
#define ui_help_small "12:16,1:-3"
#define ui_disarm_small "12:16,1:12"
#define ui_grab_small "12:32,1:12"
#define ui_harm_small "12:32,1:-3"



//#define ui_swapbutton "6:-16,1:5" //Unused


//#define ui_headset "SOUTH,8"
#define ui_hand "6:14,1:5"
#define ui_hstore1 "5,5"
#define ui_resist "EAST+1,SOUTH-1"
#define ui_sleep "EAST+1, NORTH-13"
#define ui_rest "EAST+1, NORTH-14"


#define ui_iarrowleft "SOUTH-1,11"
#define ui_iarrowright "SOUTH-1,13"




obj/hud/New(var/type = 0)
	instantiate(type)
	..()
	return


/obj/hud/proc/other_update()

	if(!mymob) return
	if(show_otherinventory)
		if(mymob:shoes) mymob:shoes:screen_loc = ui_shoes
		if(mymob:gloves) mymob:gloves:screen_loc = ui_gloves
		if(mymob:l_ear) mymob:l_ear:screen_loc = ui_lear
		if(mymob:r_ear) mymob:r_ear:screen_loc = ui_rear
		//if(mymob:s_store) mymob:s_store:screen_loc = ui_sstore1
		if(mymob:glasses) mymob:glasses:screen_loc = ui_glasses
		if(mymob:w_uniform) mymob:w_uniform:screen_loc = ui_iclothing
		if(mymob:wear_suit) mymob:wear_suit:screen_loc = ui_oclothing
		if(mymob:wear_mask) mymob:wear_mask:screen_loc = ui_mask
		if(mymob:head) mymob:head:screen_loc = ui_head
	else
		if(istype(mymob, /mob/living/carbon/human))
			if(mymob:shoes) mymob:shoes:screen_loc = null
			if(mymob:gloves) mymob:gloves:screen_loc = null
			if(mymob:l_ear) mymob:l_ear:screen_loc = null
			if(mymob:r_ear) mymob:r_ear:screen_loc = null
			//if(mymob:s_store) mymob:s_store:screen_loc = null
			if(mymob:glasses) mymob:glasses:screen_loc = null
			if(mymob:w_uniform) mymob:w_uniform:screen_loc = null
			if(mymob:wear_suit) mymob:wear_suit:screen_loc = null
			if(mymob:wear_mask) mymob:wear_mask:screen_loc = null
			if(mymob:head) mymob:head:screen_loc = null


/obj/hud/var/show_otherinventory = 1
/obj/hud/var/obj/screen/action_intent
/obj/hud/var/obj/screen/hurt_intent
/obj/hud/var/obj/screen/disarm_intent
/obj/hud/var/obj/screen/help_intent
/obj/hud/var/obj/screen/grab_intent
/obj/hud/var/obj/screen/move_intent

/obj/hud/proc/instantiate(var/type = 0)

	mymob = loc
	if(!istype(mymob, /mob)) return 0

	if(ishuman(mymob))
		human_hud(mymob.UI) // Pass the player the UI style chosen in preferences

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
