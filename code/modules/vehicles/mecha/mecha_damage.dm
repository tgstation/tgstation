/// tries to repair any internal damage and plays fluff for it
/obj/vehicle/sealed/mecha/proc/try_repair_int_damage(mob/user, flag_to_heal)
	balloon_alert(user, get_int_repair_fluff_start(flag_to_heal))
	log_message("[key_name(user)] starting internal damage repair for flag [flag_to_heal]", LOG_MECHA)
	if(!do_after(user, 10 SECONDS, src))
		balloon_alert(user, get_int_repair_fluff_fail(flag_to_heal))
		log_message("Internal damage repair for flag [flag_to_heal] failed.", LOG_MECHA, color="red")
		return
	clear_internal_damage(flag_to_heal)
	balloon_alert(user, get_int_repair_fluff_end(flag_to_heal))
	log_message("Finished internal damage repair for flag [flag_to_heal]", LOG_MECHA)

///gets the starting balloon alert flufftext
/obj/vehicle/sealed/mecha/proc/get_int_repair_fluff_start(flag)
	switch(flag)
		if(MECHA_INT_FIRE)
			return "activating internal fire supression..."
		if(MECHA_INT_TEMP_CONTROL)
			return "resetting temperature module..."
		if(MECHA_INT_TANK_BREACH)
			return "activating tank sealant..."
		if(MECHA_INT_CONTROL_LOST)
			return "recalibrating coordination system..."

///gets the successful finish balloon alert flufftext
/obj/vehicle/sealed/mecha/proc/get_int_repair_fluff_end(flag)
	switch(flag)
		if(MECHA_INT_FIRE)
			return "internal fire supressed"
		if(MECHA_INT_TEMP_CONTROL)
			return "temperature chip reactivated"
		if(MECHA_INT_TANK_BREACH)
			return "air tank sealed"
		if(MECHA_INT_CONTROL_LOST)
			return "coordination re-established"

///gets the on-fail balloon alert flufftext
/obj/vehicle/sealed/mecha/proc/get_int_repair_fluff_fail(flag)
	switch(flag)
		if(MECHA_INT_FIRE)
			return "fire supression canceled"
		if(MECHA_INT_TEMP_CONTROL)
			return "reset aborted"
		if(MECHA_INT_TANK_BREACH)
			return "sealant deactivated"
		if(MECHA_INT_CONTROL_LOST)
			return "recalibration failed"

/obj/vehicle/sealed/mecha/proc/set_internal_damage(int_dam_flag)
	internal_damage |= int_dam_flag
	log_message("Internal damage of type [int_dam_flag].", LOG_MECHA)
	SEND_SOUND(occupants, sound('sound/machines/warning-buzzer.ogg',wait=0))
	diag_hud_set_mechstat()

/obj/vehicle/sealed/mecha/proc/clear_internal_damage(int_dam_flag)
	if(internal_damage & int_dam_flag)
		switch(int_dam_flag)
			if(MECHA_INT_TEMP_CONTROL)
				to_chat(occupants, "[icon2html(src, occupants)][span_boldnotice("Life support system reactivated.")]")
			if(MECHA_INT_FIRE)
				to_chat(occupants, "[icon2html(src, occupants)][span_boldnotice("Internal fire extinguished.")]")
			if(MECHA_INT_TANK_BREACH)
				to_chat(occupants, "[icon2html(src, occupants)][span_boldnotice("Damaged internal tank has been sealed.")]")
	internal_damage &= ~int_dam_flag
	diag_hud_set_mechstat()
