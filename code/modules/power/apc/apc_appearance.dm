// update the APC icon to show the three base states
// also add overlays for indicator lights
/obj/machinery/power/apc/update_appearance(updates=check_updates())
	icon_update_needed = FALSE
	if(!updates)
		return

	. = ..()
	if(update_overlay)
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

/obj/machinery/power/apc/update_overlays()
	. = ..()

	if(update_overlay & UPOVERLAY_TERMINAL)
		. += mutable_appearance(icon, "terminal")

	if(update_overlay & UPSTATE_CELL_IN)
		. += mutable_appearance(icon, "cell")

	if(update_overlay & UPSTATE_WIREEXP)
		. += mutable_appearance(icon, "tray")

		if(update_overlay & UPOVERLAY_ELECTRONICS_INSERT)
			. += mutable_appearance(icon, "electronics")
		if(update_overlay & UPOVERLAY_TERMINAL)
			. += mutable_appearance(icon, "wires_secured")

	// Wallening todo: this will render below the byond darkness plane when screwed? open, and get cut off
	// Figure out how you want to handle that, thanks
	if(update_overlay & UPSTATE_OPENED1)
		. += mutable_appearance(icon, "hatch-open")
	else if(!(update_overlay & UPSTATE_OPENED2))
		. += mutable_appearance(icon, "hatch-shut")

	if(!locked)
		. += mutable_appearance(icon, "apc_unlocked")

	if(update_overlay & UPSTATE_BROKE)
		. += mutable_appearance(icon, "broken_overlay")

	if((machine_stat & (BROKEN|MAINT)))
		return

	// If we're emagged, these'll get temporarially overrided by the flickering overlay
	. += mutable_appearance(icon, "state-[charging]")
	. += emissive_appearance(icon, "state-[charging]", src)

	if(!operating || update_overlay & (UPSTATE_OPENED1 | UPSTATE_OPENED2))
		return

	. += mutable_appearance(icon, "equip-[equipment]")
	. += emissive_appearance(icon, "equip-[equipment]", src)
	. += mutable_appearance(icon, "light-[lighting]")
	. += emissive_appearance(icon, "light-[lighting]", src)
	. += mutable_appearance(icon, "enviro-[environ]")
	. += emissive_appearance(icon, "enviro-[environ]", src)

/// Checks for what icon updates we will need to handle
/obj/machinery/power/apc/proc/check_updates()
	SIGNAL_HANDLER

	// Handle overlay status:
	var/new_update_overlay = NONE
	if(operating)
		new_update_overlay |= UPOVERLAY_OPERATING

	if(locked)
		new_update_overlay |= UPOVERLAY_LOCKED

	if(terminal)
		new_update_overlay |= UPOVERLAY_TERMINAL
	// Handle icon status:
	if(machine_stat & BROKEN)
		new_update_overlay |= UPSTATE_BROKE
	if(machine_stat & MAINT)
		new_update_overlay |= UPSTATE_MAINT

	if(opened)
		new_update_overlay |= (opened << UPSTATE_COVER_SHIFT)
	if(cell)
		new_update_overlay |= UPSTATE_CELL_IN

	if(panel_open)
		new_update_overlay |= UPSTATE_WIREEXP

	if(has_electronics)
		new_update_overlay |= UPOVERLAY_ELECTRONICS_INSERT

	if(has_electronics == APC_ELECTRONICS_SECURED)
		new_update_overlay |= UPOVERLAY_ELECTRONICS_FASTENED

	new_update_overlay |= (charging << UPOVERLAY_CHARGING_SHIFT)
	new_update_overlay |= (equipment << UPOVERLAY_EQUIPMENT_SHIFT)
	new_update_overlay |= (lighting << UPOVERLAY_LIGHTING_SHIFT)
	new_update_overlay |= (environ << UPOVERLAY_ENVIRON_SHIFT)

	if(new_update_overlay != update_overlay)
		update_overlay = new_update_overlay
		return UPDATE_OVERLAYS
	return NONE

// Used in process so it doesn't update the icon too much
/obj/machinery/power/apc/proc/queue_icon_update()
	icon_update_needed = TRUE

// Shows a dark-blue interface for a moment. Shouldn't appear on cameras.
/obj/machinery/power/apc/proc/flicker_hacked_icon()
	var/image/hacker_image = image(icon = icon, loc = src, icon_state = "emagged", layer = FLOAT_LAYER)
	if(!(update_overlay & (UPSTATE_OPENED1 | UPSTATE_OPENED2)))
		hacker_image.add_overlay(mutable_appearance(icon, "equip-emag"))
		hacker_image.add_overlay(emissive_appearance(icon, "equip-emag", src))
		hacker_image.add_overlay(mutable_appearance(icon, "light-emag"))
		hacker_image.add_overlay(emissive_appearance(icon, "light-emag", src))
		hacker_image.add_overlay(mutable_appearance(icon, "enviro-emag"))
		hacker_image.add_overlay(emissive_appearance(icon, "enviro-emag", src))

	var/list/mobs_to_show = list()
	// Collecting mobs the APC can see for this animation, rather than mobs that can see the APC. Important distinction, intended such that mobs on camera / with XRAY cannot see the flicker.
	for(var/mob/viewer in view(src))
		if(viewer.client)
			mobs_to_show += viewer.client
	if(malfai?.client)
		mobs_to_show |= malfai.client
	flick_overlay_global(hacker_image, mobs_to_show, 1 SECONDS)
	hacked_flicker_counter = rand(3, 5) //The counter is decrimented in the process() proc, which runs every two seconds.
