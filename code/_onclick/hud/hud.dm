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
	O.screen_loc = "WEST,SOUTH to CENTER-3,NORTH"	//West dither
	O = vimpaired[2]
	O.screen_loc = "WEST,SOUTH to EAST,CENTER-3"	//South dither
	O = vimpaired[3]
	O.screen_loc = "CENTER+3,SOUTH to EAST,NORTH"	//East dither
	O = vimpaired[4]
	O.screen_loc = "WEST,CENTER+3 to EAST,NORTH"	//North dither

	//welding mask overlay black/dither
	darkMask = newlist(/obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen)
	O = darkMask[1]
	O.screen_loc = "CENTER-5,CENTER-5 to CENTER-3,CENTER+5" //West dither
	O = darkMask[2]
	O.screen_loc = "CENTER-5,CENTER-5 to CENTER+5,CENTER-3"	//South dither
	O = darkMask[3]
	O.screen_loc = "CENTER+3,CENTER-5 to CENTER+5,CENTER+5"	//East dither
	O = darkMask[4]
	O.screen_loc = "CENTER-5,CENTER+3 to CENTER+5,CENTER+5"	//North dither
	O = darkMask[5]
	O.screen_loc = "WEST,SOUTH to CENTER-5,NORTH"	//West black
	O = darkMask[6]
	O.screen_loc = "WEST,SOUTH to EAST,CENTER-5"	//South black
	O = darkMask[7]
	O.screen_loc = "CENTER+5,SOUTH to EAST,NORTH"	//East black
	O = darkMask[8]
	O.screen_loc = "WEST,CENTER+5 to EAST,NORTH"	//North black


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
	var/hud_version = 1			//Current displayed version of the HUD
	var/inventory_shown = 1		//the inventory
	var/show_intent_icons = 0
	var/hotkey_ui_hidden = 0	//This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/obj/screen/lingchemdisplay
	var/obj/screen/lingstingdisplay
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
		show_hud(HUD_STYLE_REDUCED)

//Version denotes which style should be displayed. blank or 0 means "next version"
/datum/hud/proc/show_hud(var/version = 0)
	if(!ismob(mymob))
		return 0
	if(!mymob.client)
		return 0
	var/display_hud_version = version
	if(!display_hud_version)	//If 0 or blank, display the next hud version
		display_hud_version = hud_version + 1
	if(display_hud_version > HUD_VERSIONS)	//If the requested version number is greater than the available versions, reset back to the first version
		display_hud_version = 1

	switch(display_hud_version)
		if(HUD_STYLE_STANDARD)	//Default HUD
			hud_shown = 1	//Governs behavior of other procs
			if(adding)
				mymob.client.screen += adding
			if(other && inventory_shown)
				mymob.client.screen += other
			if(hotkeybuttons && !hotkey_ui_hidden)
				mymob.client.screen += hotkeybuttons

			action_intent.screen_loc = ui_acti //Restore intent selection to the original position
			mymob.client.screen += mymob.zone_sel				//This one is a special snowflake
			mymob.client.screen += mymob.bodytemp				//As are the rest of these...
			mymob.client.screen += mymob.fire
			mymob.client.screen += mymob.healths
			mymob.client.screen += mymob.internals
			mymob.client.screen += mymob.nutrition_icon
			mymob.client.screen += mymob.oxygen
			mymob.client.screen += mymob.pressure
			mymob.client.screen += mymob.toxin
			mymob.client.screen += lingstingdisplay
			mymob.client.screen += lingchemdisplay

			hidden_inventory_update()
			persistant_inventory_update()
			mymob.update_action_buttons()
		if(HUD_STYLE_REDUCED)	//Reduced HUD
			hud_shown = 0	//Governs behavior of other procs
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
			mymob.client.screen -= lingstingdisplay
			mymob.client.screen -= lingchemdisplay

			//These ones are a part of 'adding', 'other' or 'hotkeybuttons' but we want them to stay
			mymob.client.screen += l_hand_hud_object	//we want the hands to be visible
			mymob.client.screen += r_hand_hud_object	//we want the hands to be visible
			mymob.client.screen += action_intent		//we want the intent swticher visible
			action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.

			hidden_inventory_update()
			persistant_inventory_update()
			mymob.update_action_buttons()
		if(HUD_STYLE_NOHUD)	//No HUD
			hud_shown = 0	//Governs behavior of other procs
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
			mymob.client.screen -= mymob.bodytemp
			mymob.client.screen -= mymob.fire
			mymob.client.screen -= mymob.healths
			mymob.client.screen -= mymob.internals
			mymob.client.screen -= mymob.nutrition_icon
			mymob.client.screen -= mymob.oxygen
			mymob.client.screen -= mymob.pressure
			mymob.client.screen -= mymob.toxin
			mymob.client.screen -= lingstingdisplay
			mymob.client.screen -= lingchemdisplay

			hidden_inventory_update()
			persistant_inventory_update()
			mymob.update_action_buttons()
	hud_version = display_hud_version

//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12()
	set name = "F12"
	set hidden = 1

	if(hud_used && client)
		if(ishuman(src))
			hud_used.show_hud() //Shows the next hud preset
			usr << "<span class ='info'>Switched HUD mode.</span>"
		else
			usr << "<span class ='warning'>Inventory hiding is currently only supported for human mobs, sorry.</span>"
	else
		usr << "<span class ='warning'>This mob type does not use a HUD.</span>"
