/obj/machinery/transport
	armor_type = /datum/armor/transport_machinery
	max_integrity = 400
	integrity_failure = 0.1
	/// ID of the transport we're associated with for filtering commands
	var/configured_transport_id = TRAMSTATION_LINE_1
	/// weakref of the transport we're associated with
	var/datum/weakref/transport_ref
	var/list/methods_to_fix = list()
	var/list/repair_signals
	var/static/list/how_do_we_fix_it = list(
		"try turning it off and on again with a multitool" = TOOL_MULTITOOL,
		"try forcing an unexpected reboot with a multitool" = TOOL_MULTITOOL,
		"patch the system's call table with a multitool" = TOOL_MULTITOOL,
		"gently reset the invalid memory with a crowbar" = TOOL_CROWBAR,
		"secure its ground connection with a wrench" = TOOL_WRENCH,
		"tighten some screws with a screwdriver" = TOOL_SCREWDRIVER,
		"check its wire voltages with a multitool" = TOOL_MULTITOOL,
		"cut some excess wires with wirecutters" = TOOL_WIRECUTTER,
	)
	var/malfunctioning = FALSE

/datum/armor/transport_machinery
	melee = 40
	bullet = 10
	laser = 10
	bomb = 45
	fire = 90
	acid = 100

/obj/machinery/transport/Initialize(mapload)
	. = ..()
	if(!id_tag)
		id_tag = assign_random_name()

/obj/machinery/transport/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(held_item?.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_RMB] = panel_open ? "close panel" : "open panel"

	if(panel_open)
		if(malfunctioning || methods_to_fix.len)
			context[SCREENTIP_CONTEXT_LMB] = "repair electronics"
		if(held_item?.tool_behaviour == TOOL_CROWBAR)
			context[SCREENTIP_CONTEXT_RMB] = "deconstruct"

	if(held_item?.tool_behaviour == TOOL_WELDER)
		context[SCREENTIP_CONTEXT_LMB] = "repair frame"

	return CONTEXTUAL_SCREENTIP_SET

/**
 * Finds the tram
 *
 * Locates tram parts in the lift global list after everything is done.
 */
/obj/machinery/transport/proc/link_tram()
	for(var/datum/transport_controller/linear/tram/tram as anything in SStransport.transports_by_type[TRANSPORT_TYPE_TRAM])
		if(tram.specific_transport_id != configured_transport_id)
			continue
		transport_ref = WEAKREF(tram)
		log_transport("[id_tag]: Successfuly linked to transport ID [tram.specific_transport_id] [transport_ref]")
		break

	if(isnull(transport_ref))
		log_transport("[id_tag]: Tried to find a transport with ID [configured_transport_id], but failed!")

/obj/machinery/transport/proc/local_fault()
	if(malfunctioning || !isnull(repair_signals))
		return

	generate_repair_signals()
	malfunctioning = TRUE
	set_is_operational(FALSE)
	update_appearance()

/**
 * All subtypes have the same method of repair for consistency and predictability
 * The key of this assoc list is the "method" of how they're fixing the thing (just flavor for examine),
 * and the value is what tool they actually need to use on the thing to fix it
 */
/obj/machinery/transport/proc/generate_repair_signals()

	// Select a few methods of how to fix it
	var/list/fix_it_keys = assoc_to_keys(how_do_we_fix_it)
	methods_to_fix += pick_n_take(fix_it_keys)

	// Construct the signals
	LAZYINITLIST(repair_signals)
	for(var/tool_method as anything in methods_to_fix)
		repair_signals += COMSIG_ATOM_TOOL_ACT(how_do_we_fix_it[tool_method])

	// Register signals to make it fixable
	if(length(repair_signals))
		RegisterSignals(src, repair_signals, PROC_REF(on_machine_tooled))

/obj/machinery/transport/proc/clear_repair_signals()
	UnregisterSignal(src, repair_signals)
	LAZYNULL(repair_signals)

/obj/machinery/transport/examine(mob/user)
	. = ..()
	if(methods_to_fix)
		for(var/tool_method as anything in methods_to_fix)
			. += span_warning("It needs someone to [EXAMINE_HINT(tool_method)].")
	if(panel_open)
		. += span_notice("It can be deconstructed with a [EXAMINE_HINT("crowbar.")]")

/**
 * Signal proc for [COMSIG_ATOM_TOOL_ACT], from a variety of signals, registered on the machinery.
 *
 * We allow for someone to stop the event early by using the proper tools, hinted at in examine, on the machine
 */
/obj/machinery/transport/proc/on_machine_tooled(obj/machinery/source, mob/living/user, obj/item/tool)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(try_fix_machine), source, user, tool)
	return ITEM_INTERACT_BLOCKING

/// Attempts a do_after, and if successful, stops the event
/obj/machinery/transport/proc/try_fix_machine(obj/machinery/transport/machine, mob/living/user, obj/item/tool)
	SHOULD_CALL_PARENT(TRUE)

	machine.balloon_alert(user, "percussive maintenance...")
	if(!tool.use_tool(machine, user, 7 SECONDS, volume = 50))
		machine.balloon_alert(user, "interrupted!")
		return FALSE

	playsound(src, 'sound/machines/synth/synth_yes.ogg', 75, use_reverb = TRUE)
	machine.balloon_alert(user, "success!")
	UnregisterSignal(src, repair_signals)
	LAZYNULL(repair_signals)
	methods_to_fix = list()
	malfunctioning = FALSE
	set_machine_stat(machine_stat & ~EMAGGED)
	set_is_operational(TRUE)
	update_appearance()
	return TRUE

/obj/machinery/transport/welder_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return
	if(atom_integrity >= max_integrity)
		balloon_alert(user, "it doesn't need repairs!")
		return TRUE
	balloon_alert(user, "repairing...")
	if(!tool.use_tool(src, user, 4 SECONDS, amount = 0, volume=50))
		return TRUE
	balloon_alert(user, "repaired")
	atom_integrity = max_integrity
	set_machine_stat(machine_stat & ~BROKEN)
	update_appearance()
	return TRUE

/obj/item/wallframe/tram/try_build(obj/structure/tram/on_tram, mob/user)
	if(get_dist(on_tram,user) > 1)
		balloon_alert(user, "you are too far!")
		return

	var/floor_to_tram = get_dir(user, on_tram)
	if(!(floor_to_tram in GLOB.cardinals))
		balloon_alert(user, "stand in line with tram wall!")
		return

	var/turf/tram_turf = get_turf(user)
	var/obj/structure/thermoplastic/tram_floor = locate() in tram_turf
	if(!istype(tram_floor))
		balloon_alert(user, "needs tram!")
		return

	if(check_wall_item(tram_turf, floor_to_tram, wall_external))
		balloon_alert(user, "already something here!")
		return

	return TRUE

/obj/item/wallframe/tram/attach(obj/structure/tram/on_tram, mob/user)
	if(result_path)
		playsound(src.loc, 'sound/machines/click.ogg', 75, TRUE)
		user.visible_message(span_notice("[user.name] installs [src] on the tram."),
			span_notice("You install [src] on the tram."),
			span_hear("You hear clicking."))
		var/floor_to_tram = get_dir(user, on_tram)

		var/obj/cabinet = new result_path(get_turf(user), floor_to_tram, TRUE)
		cabinet.setDir(floor_to_tram)

		if(pixel_shift)
			switch(floor_to_tram)
				if(NORTH)
					cabinet.pixel_y = pixel_shift
				if(SOUTH)
					cabinet.pixel_y = -pixel_shift
				if(EAST)
					cabinet.pixel_x = pixel_shift
				if(WEST)
					cabinet.pixel_x = -pixel_shift
		after_attach(cabinet)

	qdel(src)
