// update the APC icon to show the three base states
// also add overlays for indicator lights
/obj/machinery/power/apc/update_appearance(updates=check_updates())
	icon_update_needed = FALSE
	if(!updates)
		return

	. = ..()
	// And now, separately for cleanness, the lighting changing
	if(update_overlay & UPSTATE_BLUESCREEN)
		set_light_color(LIGHT_COLOR_BLUE)
		set_light(light_on_range)
		return

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

	if(update_overlay & UPSTATE_BLUESCREEN)
		. += mutable_appearance(icon, "emagged")
		. += emissive_appearance(icon, "emagged", src)

		if(update_overlay & (UPSTATE_OPENED1 | UPSTATE_OPENED2))
			return

		. += mutable_appearance(icon, "equip-0")
		. += emissive_appearance(icon, "equip-0", src)
		. += mutable_appearance(icon, "light-0")
		. += emissive_appearance(icon, "light-0", src)
		. += mutable_appearance(icon, "enviro-0")
		. += emissive_appearance(icon, "enviro-0", src)
		return

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

	if((obj_flags & EMAGGED) || malfai)
		new_update_overlay |= UPSTATE_BLUESCREEN

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
