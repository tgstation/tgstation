/*
	The global hud:
	Uses the same visual objects for all players.
*/
var/datum/global_hud/global_hud = new()

/datum/global_hud
	var/obj/screen/druggy
	var/obj/screen/blurry
	var/list/vimpaired
	var/list/darkMask

/datum/global_hud/New()
	//420erryday psychedellic colours screen overlay for when you are high
	druggy = new /obj/screen()
	druggy.screen_loc = "WEST,SOUTH to EAST,NORTH"
	druggy.icon_state = "druggy"
	druggy.blend_mode = BLEND_MULTIPLY
	druggy.layer = 17
	druggy.mouse_opacity = 0

	//that white blurry effect you get when you eyes are damaged
	blurry = new /obj/screen()
	blurry.screen_loc = "WEST,SOUTH to EAST,NORTH"
	blurry.icon_state = "blurry"
	blurry.layer = 17
	blurry.mouse_opacity = 0

	var/obj/screen/O
	var/i
	//that nasty looking dither you  get when you're short-sighted
	vimpaired = newlist(/obj/screen,/obj/screen,/obj/screen,/obj/screen)
	O = vimpaired[1]
	O.screen_loc = "1,1 to 5,15"
	O = vimpaired[2]
	O.screen_loc = "6,1 to 10,5"
	O = vimpaired[3]
	O.screen_loc = "6,11 to 10,15"
	O = vimpaired[4]
	O.screen_loc = "11,1 to 15,15"

	//welding mask overlay black/dither
	darkMask = newlist(/obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen)
	O = darkMask[1]
	O.screen_loc = "3,3 to 5,13"
	O = darkMask[2]
	O.screen_loc = "6,3 to 10,5"
	O = darkMask[3]
	O.screen_loc = "6,11 to 10,13"
	O = darkMask[4]
	O.screen_loc = "11,3 to 13,13"
	O = darkMask[5]
	O.screen_loc = "1,1 to 15,2"
	O = darkMask[6]
	O.screen_loc = "1,3 to 2,15"
	O = darkMask[7]
	O.screen_loc = "14,3 to 15,15"
	O = darkMask[8]
	O.screen_loc = "3,14 to 13,15"


	for(i = 1, i <= 4, i++)
		O = vimpaired[i]
		O.icon_state = "dither50"
		O.blend_mode = BLEND_MULTIPLY
		O.layer = 17
		O.mouse_opacity = 0

		O = darkMask[i]
		O.icon_state = "dither50"
		O.blend_mode = BLEND_MULTIPLY
		O.layer = 17
		O.mouse_opacity = 0

	for(i = 5, i <= 8, i++)
		O = darkMask[i]
		O.icon_state = "black"
		O.blend_mode = BLEND_MULTIPLY
		O.layer = 17
		O.mouse_opacity = 0

/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

/datum/hud
	var/mob/mymob

	var/hud_shown = 1			//Used for the HUD toggle (F12)
	var/inventory_shown = 1		//the inventory
	var/show_intent_icons = 0
	var/hotkey_ui_hidden = 0	//This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/obj/screen/lingchemdisplay
	var/obj/screen/blobpwrdisplay
	var/obj/screen/blobhealthdisplay
	var/obj/screen/alien_plasma_display
	var/obj/screen/r_hand_hud_object
	var/obj/screen/l_hand_hud_object
	var/obj/screen/action_intent
	var/obj/screen/move_intent

	var/list/adding
	var/list/other
	var/list/obj/screen/hotkeybuttons

	var/list/obj/screen/item_action/item_action_list = list()	//Used for the item action ui buttons.


datum/hud/New(mob/owner)
	mymob = owner
	instantiate()
	..()


/datum/hud/proc/hidden_inventory_update()
	if(!mymob)
		return

	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob
		if(H.handcuffed)
			H.handcuffed.screen_loc = null	//no handcuffs in my UI!
		if(inventory_shown && hud_shown)
			if(H.shoes)		H.shoes.screen_loc = ui_shoes
			if(H.gloves)	H.gloves.screen_loc = ui_gloves
			if(H.ears)		H.ears.screen_loc = ui_ears
			if(H.glasses)	H.glasses.screen_loc = ui_glasses
			if(H.w_uniform)	H.w_uniform.screen_loc = ui_iclothing
			if(H.wear_suit)	H.wear_suit.screen_loc = ui_oclothing
			if(H.wear_mask)	H.wear_mask.screen_loc = ui_mask
			if(H.head)		H.head.screen_loc = ui_head
		else
			if(H.shoes)		H.shoes.screen_loc = null
			if(H.gloves)	H.gloves.screen_loc = null
			if(H.ears)		H.ears.screen_loc = null
			if(H.glasses)	H.glasses.screen_loc = null
			if(H.w_uniform)	H.w_uniform.screen_loc = null
			if(H.wear_suit)	H.wear_suit.screen_loc = null
			if(H.wear_mask)	H.wear_mask.screen_loc = null
			if(H.head)		H.head.screen_loc = null


/datum/hud/proc/persistant_inventory_update()
	if(!mymob)
		return

	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob
		if(hud_shown)
			if(H.s_store)	H.s_store.screen_loc = ui_sstore1
			if(H.wear_id)	H.wear_id.screen_loc = ui_id
			if(H.belt)		H.belt.screen_loc = ui_belt
			if(H.back)		H.back.screen_loc = ui_back
			if(H.l_store)	H.l_store.screen_loc = ui_storage1
			if(H.r_store)	H.r_store.screen_loc = ui_storage2
		else
			if(H.s_store)	H.s_store.screen_loc = null
			if(H.wear_id)	H.wear_id.screen_loc = null
			if(H.belt)		H.belt.screen_loc = null
			if(H.back)		H.back.screen_loc = null
			if(H.l_store)	H.l_store.screen_loc = null
			if(H.r_store)	H.r_store.screen_loc = null


/datum/hud/proc/instantiate()
	if(!ismob(mymob))
		return 0
	if(!mymob.client)
		return 0

	var/ui_style = ui_style2icon(mymob.client.prefs.UI_style)

	if(ishuman(mymob))
		human_hud(ui_style) // Pass the player the UI style chosen in preferences
	else if(ismonkey(mymob))
		monkey_hud(ui_style)
	else if(isbrain(mymob))
		brain_hud(ui_style)
	else if(islarva(mymob))
		larva_hud()
	else if(isalien(mymob))
		alien_hud()
	else if(isAI(mymob))
		ai_hud()
	else if(isrobot(mymob))
		robot_hud()
	else if(isobserver(mymob))
		ghost_hud()
	else if(isovermind(mymob))
		blob_hud()

	if(istype(mymob.loc,/obj/mecha))
		hide_hud()


/datum/hud/proc/hide_hud() // hide hands is not currently used by anything but could be
	if(!ismob(mymob))
		return 0
	if(!mymob.client)
		return 0
	if(hud_shown)
		hud_shown = 0
		if(adding)
			mymob.client.screen -= adding
		if(other)
			mymob.client.screen -= other
		if(hotkeybuttons)
			mymob.client.screen -= hotkeybuttons
		if(item_action_list)
			mymob.client.screen -= item_action_list

		//These ones are not a part of 'adding', 'other' or 'hotkeybuttons' but we want them gone.
		mymob.client.screen -= mymob.zone_sel	//zone_sel is a mob variable for some reason.

		//These ones are a part of 'adding', 'other' or 'hotkeybuttons' but we want them to stay
		mymob.client.screen += l_hand_hud_object	//we want the hands to be visible
		mymob.client.screen += r_hand_hud_object	//we want the hands to be visible
		mymob.client.screen += action_intent		//we want the intent swticher visible
		action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.

		hidden_inventory_update()
		persistant_inventory_update()
		mymob.update_action_buttons()

/datum/hud/proc/show_hud()
	if(!ismob(mymob))
		return 0
	if(!mymob.client)
		return 0
	if(!hud_shown)
		hud_shown = 1
		if(adding)
			mymob.client.screen += adding
		if(other && inventory_shown)
			mymob.client.screen += other
		if(hotkeybuttons && !hotkey_ui_hidden)
			mymob.client.screen += hotkeybuttons

		action_intent.screen_loc = ui_acti //Restore intent selection to the original position
		mymob.client.screen += mymob.zone_sel				//This one is a special snowflake
		hidden_inventory_update()
		persistant_inventory_update()
		mymob.update_action_buttons()

//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12()
	set name = "F12"
	set hidden = 1

	if(hud_used && client)
		if(ishuman(src))
			if(hud_used.hud_shown)
				hud_used.hide_hud()
			else
				hud_used.show_hud()
		else
			usr << "\red Inventory hiding is currently only supported for human mobs, sorry."
	else
		usr << "\red This mob type does not use a HUD."
