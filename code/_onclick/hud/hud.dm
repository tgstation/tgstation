/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

/datum/hud
	var/mob/mymob

	var/hud_shown = 1			//Used for the HUD toggle (F12)
	var/hud_version = 1			//Current displayed version of the HUD
	var/inventory_shown = 0		//Equipped item inventory
	var/show_intent_icons = 0
	var/hotkey_ui_hidden = 0	//This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/obj/screen/ling/chems/lingchemdisplay
	var/obj/screen/ling/sting/lingstingdisplay

	var/obj/screen/blobpwrdisplay

	var/obj/screen/alien_plasma_display
	var/obj/screen/alien_queen_finder

	var/obj/screen/devil/soul_counter/devilsouldisplay

	var/obj/screen/deity_power_display
	var/obj/screen/deity_follower_display

	var/obj/screen/nightvisionicon
	var/obj/screen/action_intent
	var/obj/screen/zone_select
	var/obj/screen/pull_icon
	var/obj/screen/throw_icon
	var/obj/screen/module_store_icon

	var/list/wheels = list() //list of the wheel screen objects

	var/list/static_inventory = list() //the screen objects which are static
	var/list/toggleable_inventory = list() //the screen objects which can be hidden
	var/list/obj/screen/hotkeybuttons = list() //the buttons that can be used via hotkeys
	var/list/infodisplay = list() //the screen objects that display mob info (health, alien plasma, etc...)
	var/list/screenoverlays = list() //the screen objects used as whole screen overlays (flash, damageoverlay, etc...)
	var/list/inv_slots[slots_amt] // /obj/screen/inventory objects, ordered by their slot ID.
	var/list/hand_slots // /obj/screen/inventory/hand objects, assoc list of "[held_index]" = object
	var/list/obj/screen/plane_master/plane_masters = list() // see "appearance_flags" in the ref, assoc list of "[plane]" = object

	var/obj/screen/movable/action_button/hide_toggle/hide_actions_toggle
	var/action_buttons_hidden = 0

	var/obj/screen/healths
	var/obj/screen/healthdoll
	var/obj/screen/internals

	var/ui_style_icon = 'icons/mob/screen_midnight.dmi'

/datum/hud/New(mob/owner , ui_style = 'icons/mob/screen_midnight.dmi')
	mymob = owner

	ui_style_icon = ui_style

	hide_actions_toggle = new
	hide_actions_toggle.InitialiseIcon(src)

	hand_slots = list()

	for(var/mytype in subtypesof(/obj/screen/plane_master))
		var/obj/screen/plane_master/instance = new mytype()
		plane_masters["[instance.plane]"] = instance

/datum/hud/Destroy()
	if(mymob.hud_used == src)
		mymob.hud_used = null

	qdel(hide_actions_toggle)
	hide_actions_toggle = null

	qdel(module_store_icon)
	module_store_icon = null

	wheels = null //all wheels are also in static_inventory

	if(static_inventory.len)
		for(var/thing in static_inventory)
			qdel(thing)
		static_inventory.Cut()

	inv_slots.Cut()
	action_intent = null
	zone_select = null
	pull_icon = null

	if(toggleable_inventory.len)
		for(var/thing in toggleable_inventory)
			qdel(thing)
		toggleable_inventory.Cut()

	if(hotkeybuttons.len)
		for(var/thing in hotkeybuttons)
			qdel(thing)
		hotkeybuttons.Cut()

	throw_icon = null

	if(infodisplay.len)
		for(var/thing in infodisplay)
			qdel(thing)
		infodisplay.Cut()

	healths = null
	healthdoll = null
	internals = null
	lingchemdisplay = null
	devilsouldisplay = null
	lingstingdisplay = null
	blobpwrdisplay = null
	alien_plasma_display = null
	alien_queen_finder = null
	deity_power_display = null
	deity_follower_display = null
	nightvisionicon = null

	if(plane_masters.len)
		for(var/thing in plane_masters)
			qdel(plane_masters[thing])
		plane_masters.Cut()

	if(screenoverlays.len)
		for(var/thing in screenoverlays)
			qdel(thing)
		screenoverlays.Cut()
	mymob = null
	return ..()

/mob/proc/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud(src)

//Version denotes which style should be displayed. blank or 0 means "next version"
/datum/hud/proc/show_hud(version = 0,mob/viewmob)
	if(!ismob(mymob))
		return 0
	if(!mymob.client)
		return 0

	var/mob/screenmob = viewmob || mymob

	screenmob.client.screen = list()

	var/display_hud_version = version
	if(!display_hud_version)	//If 0 or blank, display the next hud version
		display_hud_version = hud_version + 1
	if(display_hud_version > HUD_VERSIONS)	//If the requested version number is greater than the available versions, reset back to the first version
		display_hud_version = 1

	switch(display_hud_version)
		if(HUD_STYLE_STANDARD)	//Default HUD
			hud_shown = 1	//Governs behavior of other procs
			if(static_inventory.len)
				screenmob.client.screen += static_inventory
			if(toggleable_inventory.len && screenmob.hud_used && screenmob.hud_used.inventory_shown)
				screenmob.client.screen += toggleable_inventory
			if(hotkeybuttons.len && !hotkey_ui_hidden)
				screenmob.client.screen += hotkeybuttons
			if(infodisplay.len)
				screenmob.client.screen += infodisplay

			mymob.client.screen += hide_actions_toggle

			if(action_intent)
				action_intent.screen_loc = initial(action_intent.screen_loc) //Restore intent selection to the original position

		if(HUD_STYLE_REDUCED)	//Reduced HUD
			hud_shown = 0	//Governs behavior of other procs
			if(static_inventory.len)
				screenmob.client.screen -= static_inventory
			if(toggleable_inventory.len)
				screenmob.client.screen -= toggleable_inventory
			if(hotkeybuttons.len)
				screenmob.client.screen -= hotkeybuttons
			if(infodisplay.len)
				screenmob.client.screen += infodisplay

			//These ones are a part of 'static_inventory', 'toggleable_inventory' or 'hotkeybuttons' but we want them to stay
			for(var/h in hand_slots)
				var/obj/screen/hand = hand_slots[h]
				if(hand)
					screenmob.client.screen += hand
			if(action_intent)
				screenmob.client.screen += action_intent		//we want the intent switcher visible
				action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.

		if(HUD_STYLE_NOHUD)	//No HUD
			hud_shown = 0	//Governs behavior of other procs
			if(static_inventory.len)
				screenmob.client.screen -= static_inventory
			if(toggleable_inventory.len)
				screenmob.client.screen -= toggleable_inventory
			if(hotkeybuttons.len)
				screenmob.client.screen -= hotkeybuttons
			if(infodisplay.len)
				screenmob.client.screen -= infodisplay

	if(plane_masters.len)
		for(var/thing in plane_masters)
			screenmob.client.screen += plane_masters[thing]
	hud_version = display_hud_version
	persistent_inventory_update(screenmob)
	mymob.update_action_buttons(1)
	reorganize_alerts()
	mymob.reload_fullscreen()
	create_parallax()


/datum/hud/human/show_hud(version = 0,mob/viewmob)
	..()
	hidden_inventory_update(viewmob)

/datum/hud/robot/show_hud(version = 0)
	..()
	update_robot_modules_display()

/datum/hud/proc/hidden_inventory_update()
	return

/datum/hud/proc/persistent_inventory_update(mob/viewer)
	if(!mymob)
		return
	var/mob/living/L = mymob

	var/mob/screenmob = viewer || L

	for(var/X in wheels)
		var/obj/screen/wheel/W = X
		if(W.toggled)
			screenmob.client.screen |= W.buttons_list
		else
			screenmob.client.screen -= W.buttons_list

//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12()
	set name = "F12"
	set hidden = 1

	if(hud_used && client)
		hud_used.show_hud() //Shows the next hud preset
		usr << "<span class ='info'>Switched HUD mode. Press F12 to toggle.</span>"
	else
		usr << "<span class ='warning'>This mob type does not use a HUD.</span>"


//(re)builds the hand ui slots, throwing away old ones
//not really worth jugglying existing ones so we just scrap+rebuild
//9/10 this is only called once per mob and only for 2 hands
/datum/hud/proc/build_hand_slots(ui_style = 'icons/mob/screen_midnight.dmi')
	for(var/h in hand_slots)
		var/obj/screen/inventory/hand/H = hand_slots[h]
		if(H)
			static_inventory -= H
	hand_slots = list()
	var/obj/screen/inventory/hand/hand_box
	for(var/i in 1 to mymob.held_items.len)
		hand_box = new /obj/screen/inventory/hand()
		hand_box.name = mymob.get_held_index_name(i)
		hand_box.icon = ui_style
		hand_box.icon_state = "hand_[mymob.held_index_to_dir(i)]"
		hand_box.screen_loc = ui_hand_position(i)
		hand_box.held_index = i
		hand_slots["[i]"] = hand_box
		hand_box.hud = src
		static_inventory += hand_box
		hand_box.update_icon()

	var/i = 1
	for(var/obj/screen/swap_hand/SH in static_inventory)
		SH.screen_loc = ui_swaphand_position(mymob,!(i % 2) ? 2: 1)
		i++
	for(var/obj/screen/human/equip/E in static_inventory)
		E.screen_loc = ui_equip_position(mymob)
	if(mymob.hud_used)
		show_hud(HUD_STYLE_STANDARD,mymob)