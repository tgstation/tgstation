/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

/datum/hud
	var/mob/mymob

	var/obj/screen/grab_intent
	var/obj/screen/hurt_intent
	var/obj/screen/disarm_intent
	var/obj/screen/help_intent

	var/hud_shown = 1			//Used for the HUD toggle (F12)
	var/inventory_shown = 1		//the inventory
	var/show_intent_icons = 0
	var/hotkey_ui_hidden = 0	//This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/obj/screen/lingchemdisplay
	var/obj/screen/blobpwrdisplay
	var/obj/screen/blobhealthdisplay
	var/obj/screen/vampire_blood_display // /vg/
	var/obj/screen/r_hand_hud_object
	var/obj/screen/l_hand_hud_object
	var/obj/screen/action_intent
	var/obj/screen/move_intent

	var/list/adding
	var/list/other
	var/list/obj/screen/hotkeybuttons

	var/list/obj/screen/item_action/item_action_list = list()	//Used for the item action ui buttons.

/datum/hud/New(mob/owner)
	mymob = owner
	instantiate()
	..()

/datum/hud/Destroy()
	..()
	grab_intent = null
	hurt_intent = null
	disarm_intent = null
	help_intent = null
	lingchemdisplay = null
	blobpwrdisplay = null
	blobhealthdisplay = null
	vampire_blood_display = null
	r_hand_hud_object = null
	l_hand_hud_object = null
	action_intent = null
	move_intent = null
	adding = null
	other = null
	hotkeybuttons = null
	item_action_list = null
	mymob = null


/datum/hud/proc/hidden_inventory_update()
	if(!mymob)
		return

	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob
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


	var/ui_style
	var/ui_color
	var/ui_alpha
	if(!mymob.client.prefs)
		ui_style = ui_style2icon("Midnight")
		ui_color = null
		ui_alpha = 255
	else
		ui_style = ui_style2icon(mymob.client.prefs.UI_style)
		ui_color = mymob.client.prefs.UI_style_color
		ui_alpha = mymob.client.prefs.UI_style_alpha

	if(ishuman(mymob))
		human_hud(ui_style, ui_color, ui_alpha) // Pass the player the UI style chosen in preferences
	else if(ismonkey(mymob))
		monkey_hud(ui_style)
	else if(iscorgi(mymob))
		corgi_hud()
	else if(isbrain(mymob))
		brain_hud(ui_style)
	else if(islarva(mymob))
		larva_hud()
	else if(isalien(mymob))
		alien_hud()
	else if(isAI(mymob))
		ai_hud()
	else if(isMoMMI(mymob))
		mommi_hud()
	else if(isrobot(mymob))
		robot_hud()
	else if(isobserver(mymob))
		ghost_hud()
	else if(isovermind(mymob))
		blob_hud()
	else if(isshade(mymob))
		shade_hud()
	else if(isconstruct(mymob))
		construct_hud()
	else if(isobserver(mymob))
		ghost_hud()
	if(isliving(mymob))
		var/obj/screen/using
		using = getFromPool(/obj/screen)
		using.dir = SOUTHWEST
		using.icon = 'icons/mob/screen1.dmi'
		using.icon_state = "block"
		using.layer = 19
		src.adding += using
		mymob:schematics_background = using


//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12()
	set name = "F12"
	set hidden = 1

	if(hud_used && client)
		if(ishuman(src))
			if(!src.client) return

			if(hud_used.hud_shown)
				hud_used.hud_shown = 0
				if(src.hud_used.adding)
					src.client.screen -= src.hud_used.adding
				if(src.hud_used.other)
					src.client.screen -= src.hud_used.other
				if(src.hud_used.hotkeybuttons)
					src.client.screen -= src.hud_used.hotkeybuttons
				if(src.hud_used.item_action_list)
					src.client.screen -= src.hud_used.item_action_list

				//Due to some poor coding some things need special treatment:
				//These ones are a part of 'adding', 'other' or 'hotkeybuttons' but we want them to stay
				src.client.screen += src.hud_used.l_hand_hud_object	//we want the hands to be visible
				src.client.screen += src.hud_used.r_hand_hud_object	//we want the hands to be visible
				src.client.screen += src.hud_used.action_intent		//we want the intent swticher visible
				src.hud_used.action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.

				//These ones are not a part of 'adding', 'other' or 'hotkeybuttons' but we want them gone.
				src.client.screen -= src.zone_sel	//zone_sel is a mob variable for some reason.

			else
				hud_used.hud_shown = 1
				if(src.hud_used.adding)
					src.client.screen += src.hud_used.adding
				if(src.hud_used.other && src.hud_used.inventory_shown)
					src.client.screen += src.hud_used.other
				if(src.hud_used.hotkeybuttons && !src.hud_used.hotkey_ui_hidden)
					src.client.screen += src.hud_used.hotkeybuttons


				src.hud_used.action_intent.screen_loc = ui_acti //Restore intent selection to the original position
				src.client.screen += src.zone_sel				//This one is a special snowflake

			hud_used.hidden_inventory_update()
			hud_used.persistant_inventory_update()
			update_action_buttons()
		else
			to_chat(usr, "<span class='warning'>Inventory hiding is currently only supported for human mobs, sorry.</span>")
	else
		to_chat(usr, "<span class='warning'>This mob type does not use a HUD.</span>")

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
	druggy = getFromPool(/obj/screen)
	druggy.screen_loc = ui_entire_screen
	druggy.icon_state = "druggy"
	druggy.layer = 17
	druggy.mouse_opacity = 0

	//that white blurry effect you get when you eyes are damaged
	blurry = getFromPool(/obj/screen)
	blurry.screen_loc = ui_entire_screen
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
	O.screen_loc = "5,1 to 10,5"
	O = vimpaired[3]
	O.screen_loc = "6,11 to 10,15"
	O = vimpaired[4]
	O.screen_loc = "11,1 to 15,15"

	//welding mask overlay black/dither
	darkMask = newlist(/obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen)
	O = darkMask[1]
	O.screen_loc = "3,3 to 5,13"
	O = darkMask[2]
	O.screen_loc = "5,3 to 10,5"
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
		O.layer = 17
		O.mouse_opacity = 0

		O = darkMask[i]
		O.icon_state = "dither50"
		O.layer = 17
		O.mouse_opacity = 0

	for(i = 5, i <= 8, i++)
		O = darkMask[i]
		O.icon_state = "black"
		O.layer = 17
		O.mouse_opacity = 0

/datum/hud/proc/toggle_show_schematics_display(var/list/override = null,clear = 0, var/obj/item/device/rcd/R)
	if(!isliving(mymob)) return

	var/mob/living/L = mymob

	L.shown_schematics_background = (!clear ? !L.shown_schematics_background : 0)
	update_schematics_display(override, clear, R)

/datum/hud/proc/update_schematics_display(var/list/override = null, clear,var/obj/item/device/rcd/R)
	if(!isliving(mymob)) return

	var/mob/living/L = mymob

	if(L.shown_schematics_background && !clear)
		if(!istype(R))
			switch(L.hand)
				if(1)
					R = L.l_hand
					if(!istype(R))
						return
				else
					R = L.r_hand
					if(!istype(R))
						return
		if((!R.schematics || !R.schematics.len) && !override)
			to_chat(usr, "<span class='danger'>This [R] has no schematics to choose from.</span>")
			return

		if(!L.schematics_background)
			return
		if(!override)
			override = R.schematics
		if(!R.closer)
			R.closer = getFromPool(/obj/screen/close)
			R.closer.icon_state = "x"
			R.closer.master = R
			R.closer.transform *= 0.8
		var/display_rows = round((override.len) / 8) +1 //+1 because round() returns floor of number
		L.schematics_background.screen_loc = "CENTER-4:16,SOUTH+1:7 to CENTER+3:16,SOUTH+[display_rows]:7"
		L.client.screen += L.schematics_background

		var/x = -4	//Start at CENTER-4,SOUTH+1
		var/y = 1

		for(var/datum/schematic in override)
			var/datum/rcd_schematic/RS = schematic
			if(!istype(RS))
				if(!istype(RS, /datum/selection_schematic))
					to_chat(usr, "<span class='danger'>Unexpected type in schematics list. [RS][RS ? "/[RS.type]" : "null"]")
					continue
			if(!RS.ourobj)
				RS.ourobj = getFromPool(/obj/screen/schematics, null, RS)
			var/obj/screen/A = RS.ourobj
			//Module is not currently active
			L.client.screen += A
			if(x < 0)
				A.screen_loc = "CENTER[x]:16,SOUTH+[y]:7"
			else
				A.screen_loc = "CENTER+[x]:16,SOUTH+[y]:7"
			A.layer = 20

			x++
			if(x == 4)
				x = -4
				y++
		R.closer.screen_loc = "CENTER[x < 0 ? "" : "+"][x]:16,SOUTH+[y]:7"
		L.client.screen += R.closer

	else
		for(var/obj/screen/schematics/A in L.client.screen)
			L.client.screen -= A
		L.client.screen -= L.schematics_background
		L.client.screen -= R.closer
		if(clear && override && override.len)
			L.shown_schematics_background = 1
			.(override, 0, R)
