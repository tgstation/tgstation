/obj/machinery/power/apc
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/apc/icons/apc.dmi'

/obj/item/wallframe/apc
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/apc/icons/apc.dmi'

/obj/machinery/power/apc/update_appearance(updates = check_updates())
	icon_update_needed = FALSE
	if(!updates)
		return FALSE

	. = ..()
	// And now, separately for cleanness, the lighting changing
	if(!update_state)
		switch(charging)
			if(APC_NOT_CHARGING)
				set_light_color("#FF0000")
			if(APC_CHARGING)
				set_light_color("#FF6600")
			if(APC_FULLY_CHARGED)
				set_light_color("#AAFF00")
		set_light(light_on_range)
		return TRUE

	if(update_state & UPSTATE_BLUESCREEN)
		set_light_color("#0066FF")
		set_light(light_on_range)
		return TRUE

	set_light(0)
