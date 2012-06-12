/obj/hud/slim
	var/obj/screen/r_hand_hud_object = null
	var/obj/screen/l_hand_hud_object = null
	var/list/obj/screen/intent_small_hud_objects = null
	var/show_intent_icons = 0
	var/list/obj/screen/hotkeybuttons = null
	var/hotkey_ui_hidden = 0 //This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)


/obj/hud/slim/New(var/type = 0)
	instantiate(type)
	//..()
	return


/obj/hud/slim/other_update()

	if(!mymob) return
	if(show_otherinventory)
		if(mymob:shoes) mymob:shoes:screen_loc = new_ui_shoes
		if(mymob:gloves) mymob:gloves:screen_loc = new_ui_gloves
		if(mymob:ears) mymob:ears:screen_loc = new_ui_ears
		//if(mymob:s_store) mymob:s_store:screen_loc = new_ui_sstore1
		if(mymob:glasses) mymob:glasses:screen_loc = new_ui_glasses
		if(mymob:w_uniform) mymob:w_uniform:screen_loc = new_ui_iclothing
		if(mymob:wear_suit) mymob:wear_suit:screen_loc = new_ui_oclothing
		if(mymob:wear_mask) mymob:wear_mask:screen_loc = new_ui_mask
		if(mymob:head) mymob:head:screen_loc = new_ui_head
	else
		if(ishuman(mymob))
			if(mymob:shoes) mymob:shoes:screen_loc = null
			if(mymob:gloves) mymob:gloves:screen_loc = null
			if(mymob:ears) mymob:ears:screen_loc = null
			//if(mymob:s_store) mymob:s_store:screen_loc = null
			if(mymob:glasses) mymob:glasses:screen_loc = null
			if(mymob:w_uniform) mymob:w_uniform:screen_loc = null
			if(mymob:wear_suit) mymob:wear_suit:screen_loc = null
			if(mymob:wear_mask) mymob:wear_mask:screen_loc = null
			if(mymob:head) mymob:head:screen_loc = null

/obj/hud/slim/proc/instantiate(var/type = 0)

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
