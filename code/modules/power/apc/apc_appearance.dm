// update the APC icon to show the three base states
// also add overlays for indicator lights
/obj/machinery/power/apc/update_appearance(updates=check_updates())
	icon_update_needed = FALSE
	if(!updates)
		return

	. = ..()
	// And now, separately for cleanness, the lighting changing
	if(!update_state)
		switch(charging)
			if(APC_NOT_CHARGING)
				set_light_color(COLOR_SOFT_RED)
			if(APC_CHARGING)
				set_light_color(LIGHT_COLOR_BLUE)
			if(APC_FULLY_CHARGED)
				set_light_color(LIGHT_COLOR_GREEN)
		set_light(light_on_range)
		return

	set_light(0)

/obj/machinery/power/apc/update_icon_state()
	if(!update_state)
		icon_state = "apc0"
		return ..()
	if(update_state & (UPSTATE_OPENED1|UPSTATE_OPENED2))
		var/basestate = "apc[cell ? 2 : 1]"
		if(update_state & UPSTATE_OPENED1)
			icon_state = (update_state & (UPSTATE_MAINT|UPSTATE_BROKE)) ? "apcmaint" : basestate
		else if(update_state & UPSTATE_OPENED2)
			icon_state = "[basestate][((update_state & UPSTATE_BROKE) || malfhack) ? "-b" : null]-nocover"
		return ..()
	if(update_state & UPSTATE_BROKE)
		icon_state = "apc-b"
		return ..()
	if(update_state & UPSTATE_WIREEXP)
		icon_state = "apcewires"
		return ..()
	if(update_state & UPSTATE_MAINT)
		icon_state = "apc0"
	return ..()

/obj/machinery/power/apc/update_overlays()
	. = ..()
	if((machine_stat & (BROKEN|MAINT)) || update_state)
		return

	. += mutable_appearance(icon, "apcox-[locked]")
	. += emissive_appearance(icon, "apcox-[locked]", src)
	. += mutable_appearance(icon, "apco3-[charging]")
	. += emissive_appearance(icon, "apco3-[charging]", src)
	if(!operating)
		return

	. += mutable_appearance(icon, "apco0-[equipment]")
	. += emissive_appearance(icon, "apco0-[equipment]", src)
	. += mutable_appearance(icon, "apco1-[lighting]")
	. += emissive_appearance(icon, "apco1-[lighting]", src)
	. += mutable_appearance(icon, "apco2-[environ]")
	. += emissive_appearance(icon, "apco2-[environ]", src)

/// Checks for what icon updates we will need to handle
/obj/machinery/power/apc/proc/check_updates()
	SIGNAL_HANDLER
	. = NONE

	// Handle icon status:
	var/new_update_state = NONE
	if(machine_stat & BROKEN)
		new_update_state |= UPSTATE_BROKE
	if(machine_stat & MAINT)
		new_update_state |= UPSTATE_MAINT

	if(opened)
		new_update_state |= (opened << UPSTATE_COVER_SHIFT)
		if(cell)
			new_update_state |= UPSTATE_CELL_IN

	else if(panel_open)
		new_update_state |= UPSTATE_WIREEXP

	if(new_update_state != update_state)
		update_state = new_update_state
		. |= UPDATE_ICON_STATE

	// Handle overlay status:
	var/new_update_overlay = NONE
	if(operating)
		new_update_overlay |= UPOVERLAY_OPERATING

	if(!update_state)
		if(locked)
			new_update_overlay |= UPOVERLAY_LOCKED

		new_update_overlay |= (charging << UPOVERLAY_CHARGING_SHIFT)
		new_update_overlay |= (equipment << UPOVERLAY_EQUIPMENT_SHIFT)
		new_update_overlay |= (lighting << UPOVERLAY_LIGHTING_SHIFT)
		new_update_overlay |= (environ << UPOVERLAY_ENVIRON_SHIFT)

	if(new_update_overlay != update_overlay)
		update_overlay = new_update_overlay
		. |= UPDATE_OVERLAYS


// Used in process so it doesn't update the icon too much
/obj/machinery/power/apc/proc/queue_icon_update()
	icon_update_needed = TRUE

// Shows a dark-blue interface for a moment. Shouldn't appear on cameras.
/obj/machinery/power/apc/proc/flicker_hacked_icon()
	if(opened != APC_COVER_CLOSED)
		return
	var/image/hacker_image = image(icon = 'icons/obj/machines/wallmounts.dmi', loc = src, icon_state = "apcemag", layer = FLOAT_LAYER)
	var/list/mobs_to_show = list()
	// Collecting mobs the APC can see for this animation, rather than mobs that can see the APC. Important distinction, intended such that mobs on camera / with XRAY cannot see the flicker.
	for(var/mob/viewer in view(src))
		if(viewer.client)
			mobs_to_show += viewer.client
	if(malfai?.client)
		mobs_to_show |= malfai.client
	flick_overlay_global(hacker_image, mobs_to_show, 1 SECONDS)
	hacked_flicker_counter = rand(3, 5) //The counter is decrimented in the process() proc, which runs every two seconds.
