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
#define ui_resist "EAST+1,SOUTH-1"
#define ui_gloves "SOUTH,5"
#define ui_glasses "SOUTH,7"
#define ui_ears "SOUTH,6"
#define ui_head "SOUTH+1,2"
#define ui_shoes "SOUTH,4"
#define ui_belt "SOUTH-1,3"
#define ui_throw "SOUTH-1,8"
#define ui_oxygen "EAST+1, NORTH-4"
#define ui_toxin "EAST+1, NORTH-6"
#define ui_internal "EAST+1, NORTH-2"
#define ui_fire "EAST+1, NORTH-8"
#define ui_temp "EAST+1, NORTH-10"
#define ui_health "EAST+1, NORTH-11"
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
	src.instantiate(type)
	..()
	return


/obj/hud/proc/other_update()

	if(!mymob) return
	if(show_otherinventory)
		if(mymob:shoes) mymob:shoes:screen_loc = ui_shoes
		if(mymob:gloves) mymob:gloves:screen_loc = ui_gloves
		if(mymob:ears) mymob:ears:screen_loc = ui_ears
//		if(mymob:w_radio) mymob:w_radio:screen_loc = ui_headset
		if(mymob:glasses) mymob:glasses:screen_loc = ui_glasses
	else
		if(mymob:shoes) mymob:shoes:screen_loc = null
		if(mymob:gloves) mymob:gloves:screen_loc = null
		if(mymob:ears) mymob:ears:screen_loc = null
//		if(mymob:w_radio) mymob:w_radio:screen_loc = null
		if(mymob:glasses) mymob:glasses:screen_loc = null


/obj/hud/var/show_otherinventory = 1
/obj/hud/var/obj/screen/action_intent
/obj/hud/var/obj/screen/move_intent

/obj/hud/proc/instantiate(var/type = 0)

	mymob = src.loc
	ASSERT(istype(mymob, /mob))

	if(istype(mymob, /mob/living/carbon/human))
		src.human_hud(mymob.UI) // Pass the player the UI style chosen in preferences

		return

	if(istype(mymob, /mob/living/carbon/monkey))
		src.monkey_hud(mymob.UI)
		return

	//aliens
	if(istype(mymob, /mob/living/carbon/alien/larva))
		src.larva_hud()
	else if(istype(mymob, /mob/living/carbon/alien))
		src.alien_hud()
		return

	if(istype(mymob, /mob/living/silicon/ai))
		src.ai_hud()
		return

	if(istype(mymob, /mob/living/silicon/robot))
		src.robot_hud()
		return

	if(istype(mymob, /mob/living/silicon/hivebot))
		src.hivebot_hud()
		return

	if(istype(mymob, /mob/living/silicon/hive_mainframe))
		src.hive_mainframe_hud()
		return

	if(istype(mymob, /mob/dead/observer))
		src.ghost_hud()
		return
