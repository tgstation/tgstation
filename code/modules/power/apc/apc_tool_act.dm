//attack with an item - open/close cover, insert cell, or (un)lock interface
/obj/machinery/power/apc/crowbar_act(mob/user, obj/item/crowbar)
	. = TRUE
	if((!opened && opened != APC_COVER_REMOVED) && !(machine_stat & BROKEN))
		if(coverlocked && !(machine_stat & MAINT)) // locked...
			balloon_alert(user, "cover is locked!")
			return
		else if(panel_open)
			balloon_alert(user, "wires prevents opening it!")
			return
		else
			opened = APC_COVER_OPENED
			update_appearance()
			return

	if((opened && has_electronics == APC_ELECTRONICS_SECURED) && !(machine_stat & BROKEN))
		opened = APC_COVER_CLOSED
		coverlocked = TRUE //closing cover relocks it
		balloon_alert(user, "locking the cover")
		update_appearance()
		return

	if(!opened || has_electronics != APC_ELECTRONICS_INSTALLED)
		return
	if(terminal)
		balloon_alert(user, "disconnect wires first!")
		return
	crowbar.play_tool_sound(src)
	if(!crowbar.use_tool(src, user, 50))
		return
	if(has_electronics != APC_ELECTRONICS_INSTALLED)
		return
	has_electronics = APC_ELECTRONICS_MISSING
	if(machine_stat & BROKEN)
		user.visible_message(span_notice("[user.name] breaks the power control board inside [name]!"), \
			span_hear("You hear a crack."))
		balloon_alert(user, "charred board breaks")
		return
	else if(obj_flags & EMAGGED)
		obj_flags &= ~EMAGGED
		user.visible_message(span_notice("[user.name] discards an emagged power control board from [name]!"))
		balloon_alert(user, "emagged board discarded")
		return
	else if(malfhack)
		user.visible_message(span_notice("[user.name] discards a strangely programmed power control board from [name]!"))
		balloon_alert(user, "reprogrammed board discarded")
		malfai = null
		malfhack = 0
		return
	user.visible_message(span_notice("[user.name] removes the power control board from [name]!"))
	balloon_alert(user, "removed the board")
	new /obj/item/electronics/apc(loc)
	return

/obj/machinery/power/apc/screwdriver_act(mob/living/user, obj/item/W)
	if(..())
		return TRUE
	. = TRUE

	if(!opened)
		if(obj_flags & EMAGGED)
			balloon_alert(user, "interface is broken!")
			return
		toggle_panel_open()
		balloon_alert(user, "wires [panel_open ? "exposed" : "unexposed"]")
		update_appearance()
		return

	if(cell)
		user.visible_message(span_notice("[user] removes \the [cell] from [src]!"))
		balloon_alert(user, "cell removed")
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
			balloon_alert(user, "board fastened")
		if(APC_ELECTRONICS_SECURED)
			has_electronics = APC_ELECTRONICS_INSTALLED
			set_machine_stat(machine_stat | MAINT)
			W.play_tool_sound(src)
			balloon_alert(user, "board unfastened")
		else
			balloon_alert(user, "no board to fasten!")
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
						span_hear("You hear welding."))
	balloon_alert(user, "welding the APC frame")
	if(!welder.use_tool(src, user, 50, volume=50, amount=3))
		return
	if((machine_stat & BROKEN) || opened == APC_COVER_REMOVED)
		new /obj/item/stack/sheet/iron(loc)
		user.visible_message(span_notice("[user.name] cuts [src] apart with [welder]."))
		balloon_alert(user, "disassembled the broken frame")
	else
		new /obj/item/wallframe/apc(loc)
		user.visible_message(span_notice("[user.name] cuts [src] from the wall with [welder]."))
		balloon_alert(user, "cut the frame from the wall")
	qdel(src)
	return TRUE

/obj/machinery/power/apc/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(!(the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS))
		return FALSE

	if(!has_electronics)
		if(machine_stat & BROKEN)
			balloon_alert(user, "frame is too damaged!")
			return FALSE
		return list("mode" = RCD_WALLFRAME, "delay" = 20, "cost" = 1)

	if(!cell)
		if(machine_stat & MAINT)
			balloon_alert(user, "no board for a cell!")
			return FALSE
		return list("mode" = RCD_WALLFRAME, "delay" = 50, "cost" = 10)

	balloon_alert(user, "has both board and cell!")
	return FALSE

/obj/machinery/power/apc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(!(the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS) || passed_mode != RCD_WALLFRAME)
		return FALSE

	if(!has_electronics)
		if(machine_stat & BROKEN)
			balloon_alert(user, "frame is too damaged!")
			return
		user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."))
		balloon_alert(user, "control board placed")
		has_electronics = TRUE
		locked = TRUE
		return TRUE

	if(!cell)
		if(machine_stat & MAINT)
			balloon_alert(user, "no board for a cell!")
			return FALSE
		var/obj/item/stock_parts/cell/crap/empty/C = new(src)
		C.forceMove(src)
		cell = C
		chargecount = 0
		user.visible_message(span_notice("[user] fabricates a weak power cell and places it into [src]."), \
		span_warning("Your [the_rcd.name] whirrs with strain as you create a weak power cell and place it into [src]!"))
		update_appearance()
		return TRUE

	balloon_alert(user, "has both board and cell!")
	return FALSE

/obj/machinery/power/apc/emag_act(mob/user)
	if((obj_flags & EMAGGED) || malfhack)
		return

	if(opened)
		balloon_alert(user, "close the cover first!")
	else if(panel_open)
		balloon_alert(user, "close the panel first!")
	else if(machine_stat & (BROKEN|MAINT))
		balloon_alert(user, "nothing happens!")
	else
		flick("apc-spark", src)
		playsound(src, SFX_SPARKS, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		obj_flags |= EMAGGED
		locked = FALSE
		balloon_alert(user, "you emag the APC")
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
	addtimer(CALLBACK(src, PROC_REF(reset), APC_RESET_EMP), 600)

/obj/machinery/power/apc/proc/togglelock(mob/living/user)
	if(obj_flags & EMAGGED)
		balloon_alert(user, "interface is broken!")
	else if(opened)
		balloon_alert(user, "close the cover first!")
	else if(panel_open)
		balloon_alert(user, "close the panel first!")
	else if(machine_stat & (BROKEN|MAINT))
		balloon_alert(user, "nothing happens!")
	else
		if(allowed(usr) && !wires.is_cut(WIRE_IDSCAN) && !malfhack && !remote_control_user)
			locked = !locked
			balloon_alert(user, locked ? "locked" : "unlocked")
			update_appearance()
			if(!locked)
				ui_interact(user)
		else
			balloon_alert(user, "access denied!")
