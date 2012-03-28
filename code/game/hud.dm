#define ui_dropbutton "SOUTH-1,7"
#define ui_swapbutton "SOUTH-1,7"
#define ui_iclothing "SOUTH-1,2"
#define ui_oclothing "SOUTH,2"
//#define ui_headset "SOUTH,8"
#define ui_rhand "SOUTH,1"
#define ui_lhand "SOUTH,3"
#define ui_id "SOUTH-1,1"
#define ui_mask "SOUTH+1,1"
#define ui_back "SOUTH+1,3"
#define ui_storage1 "SOUTH-1,4"
#define ui_storage2 "SOUTH-1,5"
#define ui_sstore1 "SOUTH+1,4"
#define ui_hstore1 "SOUTH+1,5"
#define ui_resist "EAST+1,SOUTH-1"
#define ui_gloves "SOUTH,5"
#define ui_glasses "SOUTH,7"
#define ui_ears "SOUTH,6"
#define ui_head "SOUTH+1,2"
#define ui_shoes "SOUTH,4"
#define ui_belt "SOUTH-1,3"
#define ui_throw "SOUTH-1,8"
#define ui_oxygen "EAST+1, NORTH-4"
#define ui_pressure "EAST+1, NORTH-5"
#define ui_toxin "EAST+1, NORTH-6"
#define ui_internal "EAST+1, NORTH-2"
#define ui_fire "EAST+1, NORTH-8"
#define ui_temp "EAST+1, NORTH-10"
#define ui_health "EAST+1, NORTH-11"
#define ui_nutrition "EAST+1, NORTH-12"
#define ui_pull "SOUTH-1,10"
#define ui_hand "SOUTH-1,6"
#define ui_sleep "EAST+1, NORTH-13"
#define ui_rest "EAST+1, NORTH-14"

#define ui_acti "SOUTH-1,12"
#define ui_movi "SOUTH-1,14"

#define ui_iarrowleft "SOUTH-1,11"
#define ui_iarrowright "SOUTH-1,13"

#define ui_inv1 "SOUTH-1,1"
#define ui_inv2 "SOUTH-1,2"
#define ui_inv3 "SOUTH-1,3"



obj/hud/New(var/type = 0)
	instantiate(type)
	..()
	return


/obj/hud/proc/other_update()

	if(!mymob) return
	if(show_otherinventory)
		if(mymob:shoes) mymob:shoes:screen_loc = ui_shoes
		if(mymob:gloves) mymob:gloves:screen_loc = ui_gloves
		if(mymob:ears) mymob:ears:screen_loc = ui_ears
		if(mymob:s_store) mymob:s_store:screen_loc = ui_sstore1
		if(mymob:glasses) mymob:glasses:screen_loc = ui_glasses
		if(mymob:h_store) mymob:h_store:screen_loc = ui_hstore1
	else
		if(istype(mymob, /mob/living/carbon/human))
			if(mymob:shoes) mymob:shoes:screen_loc = null
			if(mymob:gloves) mymob:gloves:screen_loc = null
			if(mymob:ears) mymob:ears:screen_loc = null
			if(mymob:s_store) mymob:s_store:screen_loc = null
			if(mymob:glasses) mymob:glasses:screen_loc = null
			if(mymob:h_store) mymob:h_store:screen_loc = null


/obj/hud/var/show_otherinventory = 1
/obj/hud/var/obj/screen/action_intent
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
