//attack with an item - open/close cover, insert cell, or (un)lock interface
/obj/machinery/power/apc/crowbar_act(mob/user, obj/item/crowbar)
	. = TRUE

	//Prying off broken cover
	if((opened == APC_COVER_CLOSED || opened == APC_COVER_OPENED) && (machine_stat & BROKEN))
		crowbar.play_tool_sound(src)
		balloon_alert(user, "prying...")
		if(!crowbar.use_tool(src, user, 5 SECONDS))
			return
		opened = APC_COVER_REMOVED
		balloon_alert(user, "cover removed")
		update_appearance()
		return

	//Opening and closing cover
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

	//Taking out the electronics
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

	//repairing the cover
	if((atom_integrity < max_integrity) && has_electronics)
		if(opened == APC_COVER_REMOVED)
			balloon_alert(user, "no cover to repair!")
			return
		if (machine_stat & BROKEN)
			balloon_alert(user, "too damaged to repair!")
			return
		if(!welder.tool_start_check(user, amount=1))
			return
		balloon_alert(user, "repairing...")
		if(welder.use_tool(src, user, 4 SECONDS, volume = 50))
			update_integrity(min(atom_integrity += 50,max_integrity))
			balloon_alert(user, "repaired")
		return TOOL_ACT_TOOLTYPE_SUCCESS

	//disassembling the frame
	if(!opened || has_electronics || terminal)
		return
	if(!welder.tool_start_check(user, amount=1))
		return
	user.visible_message(span_notice("[user.name] welds [src]."), \
						span_hear("You hear welding."))
	balloon_alert(user, "welding the APC frame")
	if(!welder.use_tool(src, user, 50, volume=50))
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
		return list("delay" = 2 SECONDS, "cost" = 1)

	if(!cell)
		if(machine_stat & MAINT)
			balloon_alert(user, "no board for a cell!")
			return FALSE
		return list("delay" = 5 SECONDS, "cost" = 10)

	balloon_alert(user, "has both board and cell!")
	return FALSE

/obj/machinery/power/apc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(!(the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS) || rcd_data["[RCD_DESIGN_MODE]"] != RCD_WALLFRAME)
		return FALSE

	if(!has_electronics)
		if(machine_stat & BROKEN)
			balloon_alert(user, "frame is too damaged!")
			return
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
		balloon_alert(user, "power cell installed")
		update_appearance()
		return TRUE

	balloon_alert(user, "has both board and cell!")
	return FALSE

/obj/machinery/power/apc/emag_act(mob/user, obj/item/card/emag/emag_card)
	if((obj_flags & EMAGGED) || malfhack)
		return FALSE

	if(opened)
		balloon_alert(user, "close the cover first!")
		return FALSE
	else if(panel_open)
		balloon_alert(user, "close the panel first!")
		return FALSE
	else if(machine_stat & (BROKEN|MAINT))
		balloon_alert(user, "nothing happens!")
		return FALSE
	else
		flick("apc-spark", src)
		playsound(src, SFX_SPARKS, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		obj_flags |= EMAGGED
		locked = FALSE
		balloon_alert(user, "interface damaged")
		update_appearance()
		return TRUE

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
		else
			balloon_alert(user, "access denied!")
