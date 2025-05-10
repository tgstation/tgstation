
/obj/machinery/airalarm/crowbar_act(mob/living/user, obj/item/tool)
	if(buildstage != AIR_ALARM_BUILD_NO_WIRES)
		return
	user.visible_message(span_notice("[user.name] removes the electronics from [name]."), \
						span_notice("You start prying out the circuit..."))
	tool.play_tool_sound(src)
	if (tool.use_tool(src, user, 20))
		if (buildstage == AIR_ALARM_BUILD_NO_WIRES)
			to_chat(user, span_notice("You remove the air alarm electronics."))
			new /obj/item/electronics/airalarm(drop_location())
			playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
			buildstage = AIR_ALARM_BUILD_NO_CIRCUIT
			update_appearance()
	return TRUE

/obj/machinery/airalarm/screwdriver_act(mob/living/user, obj/item/tool)
	if(buildstage != AIR_ALARM_BUILD_COMPLETE)
		return
	tool.play_tool_sound(src)
	toggle_panel_open()
	to_chat(user, span_notice("The wires have been [panel_open ? "exposed" : "unexposed"]."))
	update_appearance()
	return TRUE

/obj/machinery/airalarm/wirecutter_act(mob/living/user, obj/item/tool)
	if(!(buildstage == AIR_ALARM_BUILD_COMPLETE && panel_open && wires.is_all_cut()))
		return
	tool.play_tool_sound(src)
	to_chat(user, span_notice("You cut the final wires."))
	var/obj/item/stack/cable_coil/cables = new(drop_location(), 5)
	user.put_in_hands(cables)
	buildstage = AIR_ALARM_BUILD_NO_WIRES
	update_appearance()
	return TRUE

/obj/machinery/airalarm/wrench_act(mob/living/user, obj/item/tool)
	if(buildstage != AIR_ALARM_BUILD_NO_CIRCUIT)
		return
	to_chat(user, span_notice("You detach \the [src] from the wall."))
	tool.play_tool_sound(src)
	var/obj/item/wallframe/airalarm/alarm_frame = new(drop_location())
	user.put_in_hands(alarm_frame)
	qdel(src)
	return TRUE


/obj/machinery/airalarm/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if((buildstage == AIR_ALARM_BUILD_NO_CIRCUIT) && (the_rcd.construction_upgrades & RCD_UPGRADE_SIMPLE_CIRCUITS))
		return list("delay" = 2 SECONDS, "cost" = 1)
	return FALSE

/obj/machinery/airalarm/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(rcd_data["[RCD_DESIGN_MODE]"] == RCD_WALLFRAME)
		balloon_alert(user, "circuit installed")
		buildstage = AIR_ALARM_BUILD_NO_WIRES
		update_appearance()
		return TRUE
	return FALSE

/obj/machinery/airalarm/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(!can_interact(user))
		return
	if(!user.can_perform_action(src, ALLOW_SILICON_REACH) || !isturf(loc))
		return
	togglelock(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/airalarm/proc/togglelock(mob/living/user)
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, span_warning("It does nothing!"))
	else
		if(HAS_SILICON_ACCESS(user))
			locked = !locked
			return
		if(src.allowed(usr) && !wires.is_cut(WIRE_IDSCAN))
			locked = !locked
			to_chat(user, span_notice("You [ locked ? "lock" : "unlock"] the air alarm interface."))
			if(!locked)
				ui_interact(user)
		else
			to_chat(user, span_danger("Access denied."))

/obj/machinery/airalarm/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	visible_message(span_warning("Sparks fly out of [src]!"))
	balloon_alert(user, "authentication sensors scrambled")
	playsound(src, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	return TRUE

/obj/machinery/airalarm/on_deconstruction(disassembled = TRUE)
	new /obj/item/stack/sheet/iron(loc, 2)
	if((buildstage == AIR_ALARM_BUILD_NO_WIRES) || (buildstage == AIR_ALARM_BUILD_COMPLETE))
		var/obj/item/electronics/airalarm/alarm = new(loc)
		if(!disassembled)
			alarm.take_damage(alarm.max_integrity * 0.5, sound_effect = FALSE)
	if((buildstage == AIR_ALARM_BUILD_COMPLETE))
		new /obj/item/stack/cable_coil(loc, 3)

/obj/machinery/airalarm/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	update_last_used(user)
	switch(buildstage)
		if(AIR_ALARM_BUILD_COMPLETE)
			if(W.GetID())// trying to unlock the interface with an ID card
				togglelock(user)
				return
			else if(panel_open && is_wire_tool(W))
				wires.interact(user)
				return
		if(AIR_ALARM_BUILD_NO_WIRES)
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/cable = W
				if(cable.get_amount() < 5)
					to_chat(user, span_warning("You need five lengths of cable to wire the air alarm!"))
					return
				user.visible_message(span_notice("[user.name] wires the air alarm."), \
									span_notice("You start wiring the air alarm..."))
				if (do_after(user, 2 SECONDS, target = src))
					if (cable.get_amount() >= 5 && buildstage == AIR_ALARM_BUILD_NO_WIRES)
						cable.use(5)
						to_chat(user, span_notice("You wire the air alarm."))
						wires.repair()
						aidisabled = FALSE
						locked = FALSE
						shorted = FALSE
						danger_level = AIR_ALARM_ALERT_NONE
						buildstage = AIR_ALARM_BUILD_COMPLETE
						select_mode(user, /datum/air_alarm_mode/filtering)
						update_appearance()
				return
		if(AIR_ALARM_BUILD_NO_CIRCUIT)
			if(istype(W, /obj/item/electronics/airalarm))
				if(user.temporarilyRemoveItemFromInventory(W))
					to_chat(user, span_notice("You insert the circuit."))
					buildstage = AIR_ALARM_BUILD_NO_WIRES
					update_appearance()
					qdel(W)
				return

			if(istype(W, /obj/item/electroadaptive_pseudocircuit))
				var/obj/item/electroadaptive_pseudocircuit/P = W
				if(!P.adapt_circuit(user, circuit_cost = 0.025 * STANDARD_CELL_CHARGE))
					return
				user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."), \
				span_notice("You adapt an air alarm circuit and slot it into the assembly."))
				buildstage = AIR_ALARM_BUILD_NO_WIRES
				update_appearance()
				return

	return ..()

/obj/machinery/airalarm/proc/reset(wire)
	switch(wire)
		if(WIRE_POWER)
			if(!wires.is_cut(WIRE_POWER))
				shorted = FALSE
				update_appearance()
		if(WIRE_AI)
			if(!wires.is_cut(WIRE_AI))
				aidisabled = FALSE

/obj/machinery/airalarm/proc/shock(mob/user, prb)
	if((machine_stat & (NOPOWER))) // unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE //you lucked out, no shock for you
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start() //sparks always.
	if (electrocute_mob(user, get_area(src), src, 1, TRUE))
		return TRUE
	else
		return FALSE

/obj/item/electronics/airalarm
	name = "air alarm electronics"
	icon_state = "airalarm_electronics"

/obj/item/wallframe/airalarm
	name = "air alarm frame"
	desc = "Used for building Air Alarms."
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "alarm_bitem"
	result_path = /obj/machinery/airalarm
	pixel_shift = 27
