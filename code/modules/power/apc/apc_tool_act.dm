//attack with an item - open/close cover, insert cell, or (un)lock interface
/obj/machinery/power/apc/crowbar_act(mob/user, obj/item/crowbar)
	. = TRUE
	if((!opened && opened != APC_COVER_REMOVED) && !(machine_stat & BROKEN))
		if(coverlocked && !(machine_stat & MAINT)) // locked...
			to_chat(user, span_warning("The cover is locked and cannot be opened!"))
			return
		else if(panel_open)
			to_chat(user, span_warning("Exposed wires prevents you from opening it!"))
			return
		else
			opened = APC_COVER_OPENED
			update_appearance()
			return

	if((opened && has_electronics == APC_ELECTRONICS_SECURED) && !(machine_stat & BROKEN))
		opened = APC_COVER_CLOSED
		coverlocked = TRUE //closing cover relocks it
		update_appearance()
		return

	if(!opened || has_electronics != APC_ELECTRONICS_INSTALLED)
		return
	if(terminal)
		to_chat(user, span_warning("Disconnect the wires first!"))
		return
	crowbar.play_tool_sound(src)
	to_chat(user, span_notice("You attempt to remove the power control board...") )
	if(!crowbar.use_tool(src, user, 50))
		return
	if(has_electronics != APC_ELECTRONICS_INSTALLED)
		return
	has_electronics = APC_ELECTRONICS_MISSING
	if(machine_stat & BROKEN)
		user.visible_message(span_notice("[user.name] breaks the power control board inside [name]!"),\
			span_notice("You break the charred power control board and remove the remains."),
			span_hear("You hear a crack."))
		return
	else if(obj_flags & EMAGGED)
		obj_flags &= ~EMAGGED
		user.visible_message(span_notice("[user.name] discards an emagged power control board from [name]!"),\
			span_notice("You discard the emagged power control board."))
		return
	else if(malfhack)
		user.visible_message(span_notice("[user.name] discards a strangely programmed power control board from [name]!"),\
			span_notice("You discard the strangely programmed board."))
		malfai = null
		malfhack = 0
		return
	user.visible_message(span_notice("[user.name] removes the power control board from [name]!"),\
		span_notice("You remove the power control board."))
	new /obj/item/electronics/apc(loc)
	return

/obj/machinery/power/apc/screwdriver_act(mob/living/user, obj/item/W)
	if(..())
		return TRUE
	. = TRUE

	if(!opened)
		if(obj_flags & EMAGGED)
			to_chat(user, span_warning("The interface is broken!"))
			return
		panel_open = !panel_open
		to_chat(user, span_notice("The wires have been [panel_open ? "exposed" : "unexposed"]."))
		update_appearance()
		return

	if(cell)
		user.visible_message(span_notice("[user] removes \the [cell] from [src]!"), span_notice("You remove \the [cell]."))
		var/turf/user_turf = get_turf(user)
		cell.forceMove(user_turf)
		cell.update_appearance()
		cell = null
		charging = APC_NOT_CHARGING
		update_appearance()
		return

	switch (has_electronics)
		if(APC_ELECTRONICS_INSTALLED)
			has_electronics = APC_ELECTRONICS_SECURED
			set_machine_stat(machine_stat & ~MAINT)
			W.play_tool_sound(src)
			to_chat(user, span_notice("You screw the circuit electronics into place."))
		if(APC_ELECTRONICS_SECURED)
			has_electronics = APC_ELECTRONICS_INSTALLED
			set_machine_stat(machine_stat | MAINT)
			W.play_tool_sound(src)
			to_chat(user, span_notice("You unfasten the electronics."))
		else
			to_chat(user, span_warning("There is nothing to secure!"))
			return
	update_appearance()

/obj/machinery/power/apc/wirecutter_act(mob/living/user, obj/item/W)
	. = ..()
	if(terminal && opened)
		terminal.dismantle(user, W)
		return TRUE

/obj/machinery/power/apc/welder_act(mob/living/user, obj/item/welder)
	. = ..()
	if(!opened || has_electronics || terminal)
		return
	if(!welder.tool_start_check(user, amount=3))
		return
	user.visible_message(span_notice("[user.name] welds [src]."), \
						span_notice("You start welding the APC frame..."), \
						span_hear("You hear welding."))
	if(!welder.use_tool(src, user, 50, volume=50, amount=3))
		return
	if((machine_stat & BROKEN) || opened==APC_COVER_REMOVED)
		new /obj/item/stack/sheet/iron(loc)
		user.visible_message(span_notice("[user.name] cuts [src] apart with [welder]."),\
			span_notice("You disassembled the broken APC frame."))
	else
		new /obj/item/wallframe/apc(loc)
		user.visible_message(span_notice("[user.name] cuts [src] from the wall with [welder]."),\
			span_notice("You cut the APC frame from the wall."))
	qdel(src)
	return TRUE

/obj/machinery/power/apc/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(!(the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS))
		return FALSE

	if(!has_electronics)
		if(machine_stat & BROKEN)
			to_chat(user, span_warning("[src]'s frame is too damaged to support a circuit."))
			return FALSE
		return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 20, "cost" = 1)

	if(!cell)
		if(machine_stat & MAINT)
			to_chat(user, span_warning("There's no connector for a power cell."))
			return FALSE
		return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 50, "cost" = 10) //16 for a wall

	to_chat(user, span_warning("[src] has both electronics and a cell."))
	return FALSE

/obj/machinery/power/apc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(!(passed_mode & RCD_UPGRADE_SIMPLE_CIRCUITS))
		return FALSE
	if(!has_electronics)
		if(machine_stat & BROKEN)
			to_chat(user, span_warning("[src]'s frame is too damaged to support a circuit."))
			return
		user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."), \
		span_notice("You adapt a power control board and click it into place in [src]'s guts."))
		has_electronics = TRUE
		locked = TRUE
		return TRUE

	if(!cell)
		if(machine_stat & MAINT)
			to_chat(user, span_warning("There's no connector for a power cell."))
			return FALSE
		var/obj/item/stock_parts/cell/crap/empty/C = new(src)
		C.forceMove(src)
		cell = C
		chargecount = 0
		user.visible_message(span_notice("[user] fabricates a weak power cell and places it into [src]."), \
		span_warning("Your [the_rcd.name] whirrs with strain as you create a weak power cell and place it into [src]!"))
		update_appearance()
		return TRUE

	to_chat(user, span_warning("[src] has both electronics and a cell."))
	return FALSE

/obj/machinery/power/apc/emag_act(mob/user)
	if((obj_flags & EMAGGED) || malfhack)
		return

	if(opened)
		to_chat(user, span_warning("You must close the cover to swipe an ID card!"))
	else if(panel_open)
		to_chat(user, span_warning("You must close the panel first!"))
	else if(machine_stat & (BROKEN|MAINT))
		to_chat(user, span_warning("Nothing happens!"))
	else
		flick("apc-spark", src)
		playsound(src, SFX_SPARKS, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		obj_flags |= EMAGGED
		locked = FALSE
		to_chat(user, span_notice("You emag the APC interface."))
		update_appearance()

// damage and destruction acts
/obj/machinery/power/apc/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_CONTENTS))
		if(cell)
			cell.emp_act(severity)
		if(occupier)
			occupier.emp_act(severity)
	if(. & EMP_PROTECT_SELF)
		return
	lighting = APC_CHANNEL_OFF
	equipment = APC_CHANNEL_OFF
	environ = APC_CHANNEL_OFF
	update_appearance()
	update()
	addtimer(CALLBACK(src, .proc/reset, APC_RESET_EMP), 600)

/obj/machinery/power/apc/proc/togglelock(mob/living/user)
	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("The interface is broken!"))
	else if(opened)
		to_chat(user, span_warning("You must close the cover to swipe an ID card!"))
	else if(panel_open)
		to_chat(user, span_warning("You must close the panel!"))
	else if(machine_stat & (BROKEN|MAINT))
		to_chat(user, span_warning("Nothing happens!"))
	else
		if(allowed(usr) && !wires.is_cut(WIRE_IDSCAN) && !malfhack)
			locked = !locked
			to_chat(user, span_notice("You [ locked ? "lock" : "unlock"] the APC interface."))
			update_appearance()
			if(!locked)
				ui_interact(user)
		else
			to_chat(user, span_warning("Access denied."))
