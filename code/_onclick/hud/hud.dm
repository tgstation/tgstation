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

	var/obj/screen/ling/chems/lingchemdisplay
	var/obj/screen/ling/sting/lingstingdisplay

	var/obj/screen/blobpwrdisplay

	var/obj/screen/alien_plasma_display

	var/obj/screen/deity_power_display
	var/obj/screen/deity_follower_display

	var/obj/screen/nightvisionicon
	var/obj/screen/action_intent
	var/obj/screen/zone_select
	var/obj/screen/pull_icon
	var/obj/screen/throw_icon
	var/obj/screen/module_store_icon

	var/list/static_inventory = list() //the screen objects which are static
	var/list/toggleable_inventory = list() //the screen objects which can be hidden
	var/list/obj/screen/hotkeybuttons = list() //the buttons that can be used via hotkeys
	var/list/infodisplay = list() //the screen objects that display mob info (health, alien plasma, etc...)
	var/list/screenoverlays = list() //the screen objects used as whole screen overlays (flash, damageoverlay, etc...)
	var/list/inv_slots[slots_amt] // /obj/screen/inventory objects, ordered by their slot ID.

	var/obj/screen/movable/action_button/hide_toggle/hide_actions_toggle
	var/action_buttons_hidden = 0

	var/obj/screen/healths
	var/obj/screen/healthdoll
	var/obj/screen/internals

/datum/hud/New(mob/owner)
	mymob = owner
	hide_actions_toggle = new
	hide_actions_toggle.InitialiseIcon(mymob)

/datum/hud/Destroy()
	if(mymob.hud_used == src)
		mymob.hud_used = null

	qdel(hide_actions_toggle)
	hide_actions_toggle = null

	qdel(module_store_icon)
	module_store_icon = null

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
	lingstingdisplay = null
	blobpwrdisplay = null
	alien_plasma_display = null
	deity_power_display = null
	deity_follower_display = null
	nightvisionicon = null

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
/datum/hud/proc/show_hud(version = 0)
	if(!ismob(mymob))
		return 0
	if(!mymob.client)
		return 0

	mymob.client.screen = list()

	var/display_hud_version = version
	if(!display_hud_version)	//If 0 or blank, display the next hud version
		display_hud_version = hud_version + 1
	if(display_hud_version > HUD_VERSIONS)	//If the requested version number is greater than the available versions, reset back to the first version
		display_hud_version = 1

	switch(display_hud_version)
		if(HUD_STYLE_STANDARD)	//Default HUD
			hud_shown = 1	//Governs behavior of other procs
			if(static_inventory.len)
				mymob.client.screen += static_inventory
			if(toggleable_inventory.len && inventory_shown)
				mymob.client.screen += toggleable_inventory
			if(hotkeybuttons.len && !hotkey_ui_hidden)
				mymob.client.screen += hotkeybuttons
			if(infodisplay.len)
				mymob.client.screen += infodisplay

			mymob.client.screen += hide_actions_toggle

			if(action_intent)
				action_intent.screen_loc = initial(action_intent.screen_loc) //Restore intent selection to the original position

		if(HUD_STYLE_REDUCED)	//Reduced HUD
			hud_shown = 0	//Governs behavior of other procs
			if(static_inventory.len)
				mymob.client.screen -= static_inventory
			if(toggleable_inventory.len)
				mymob.client.screen -= toggleable_inventory
			if(hotkeybuttons.len)
				mymob.client.screen -= hotkeybuttons
			if(infodisplay.len)
				mymob.client.screen += infodisplay

			//These ones are a part of 'static_inventory', 'toggleable_inventory' or 'hotkeybuttons' but we want them to stay
			if(inv_slots[slot_l_hand])
				mymob.client.screen += inv_slots[slot_l_hand]	//we want the hands to be visible
			if(inv_slots[slot_r_hand])
				mymob.client.screen += inv_slots[slot_r_hand]	//we want the hands to be visible
			if(action_intent)
				mymob.client.screen += action_intent		//we want the intent switcher visible
				action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.

		if(HUD_STYLE_NOHUD)	//No HUD
			hud_shown = 0	//Governs behavior of other procs
			if(static_inventory.len)
				mymob.client.screen -= static_inventory
			if(toggleable_inventory.len)
				mymob.client.screen -= toggleable_inventory
			if(hotkeybuttons.len)
				mymob.client.screen -= hotkeybuttons
			if(infodisplay.len)
				mymob.client.screen -= infodisplay

	hud_version = display_hud_version
	persistant_inventory_update()
	mymob.update_action_buttons(1)
	reorganize_alerts()
	mymob.reload_fullscreen()


/datum/hud/human/show_hud(version = 0)
	..()
	hidden_inventory_update()

/datum/hud/robot/show_hud(version = 0)
	..()
	update_robot_modules_display()

/datum/hud/proc/hidden_inventory_update()
	return

/datum/hud/proc/persistant_inventory_update()
	return

//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12()
	set name = "F12"
	set hidden = 1

	if(hud_used && client)
		hud_used.show_hud() //Shows the next hud preset
		usr << "<span class ='info'>Switched HUD mode. Press F12 to toggle.</span>"
	else
		usr << "<span class ='warning'>This mob type does not use a HUD.</span>"

