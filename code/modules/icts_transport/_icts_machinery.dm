/obj/machinery/icts
	/// ID of the transport we're associated with for filtering commands
	var/configured_transport_id = TRAMSTATION_LINE_1
	/// weakref of the transport we're associated with
	var/datum/weakref/transport_ref
	var/list/methods_to_fix
	var/list/repair_signals
	var/static/list/how_do_we_fix_it = list(
		"try turning it off and on again" = TOOL_MULTITOOL,
		"try forcing an unexpected reboot" = TOOL_MULTITOOL,
		"patch the system's call table" = TOOL_MULTITOOL,
		"gently reset the invalid memory" = TOOL_CROWBAR,
		"secure its ground connection" = TOOL_WRENCH,
		"tighten some screws" = TOOL_SCREWDRIVER,
		"check its wire voltages" = TOOL_MULTITOOL,
		"cut some excess wires" = TOOL_WIRECUTTER,
	)

/obj/machinery/icts/proc/local_fault()
	if(machine_stat & BROKEN || repair_signals)
		return

	generate_repair_signals()
	set_machine_stat(machine_stat | BROKEN)
	set_is_operational(FALSE)
	update_appearance()

/**
 * All ICTS subtypes have the same method of repair for consistency and predictability
 * The key of this assoc list is the "method" of how they're fixing the thing (just flavor for examine),
 * and the value is what tool they actually need to use on the thing to fix it
 */
/obj/machinery/icts/proc/generate_repair_signals()

	// Select a few methods of how to fix it
	var/list/fix_it_keys = assoc_to_keys(how_do_we_fix_it)
	LAZYINITLIST(methods_to_fix)
		methods_to_fix += pick_n_take(fix_it_keys)

	// Construct the signals
	LAZYINITLIST(repair_signals)
	for(var/tool_method as anything in methods_to_fix)
		repair_signals += COMSIG_ATOM_TOOL_ACT(how_do_we_fix_it[tool_method])

	// Register signals to make it fixable
	if(length(repair_signals))
		RegisterSignals(src, repair_signals, PROC_REF(on_machine_tooled))

/obj/machinery/icts/proc/clear_repair_signals()
	UnregisterSignal(src, repair_signals)
	QDEL_LAZYLIST(repair_signals)

/obj/machinery/icts/examine(mob/user)
	. = ..()
	if(methods_to_fix)
		for(var/tool_method as anything in methods_to_fix)
			. += span_info("It needs someone to [tool_method].")

/**
 * Signal proc for [COMSIG_ATOM_TOOL_ACT], from a variety of signals, registered on the ICTS machinery.
 *
 * We allow for someone to stop the event early by using the proper tools, hinted at in examine, on the machine
 */
/obj/machinery/icts/proc/on_machine_tooled(obj/machinery/source, mob/living/user, obj/item/tool)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(try_fix_machine), source, user, tool)
	return COMPONENT_BLOCK_TOOL_ATTACK

/// Attempts a do_after, and if successful, stops the event
/obj/machinery/icts/proc/try_fix_machine(obj/machinery/icts/machine, mob/living/user, obj/item/tool)
	SHOULD_CALL_PARENT(TRUE)

	machine.balloon_alert(user, "percussive maintenance...")
	// A tider can fix it if they want,
	// but only an equipped engineer should be able to handle it effortlessly.
	if(!tool.use_tool(machine, user, 7 SECONDS, volume = 50))
		machine.balloon_alert(user, "interrupted!")
		return FALSE

	playsound(src, 'sound/machines/synth_yes.ogg', 75, use_reverb = TRUE)
	machine.balloon_alert(user, "success!")
	UnregisterSignal(src, repair_signals)
	QDEL_LAZYLIST(repair_signals)
	QDEL_LAZYLIST(methods_to_fix)
	set_machine_stat(machine_stat & ~BROKEN)
	set_machine_stat(machine_stat & ~EMAGGED)
	update_appearance()
	return TRUE

/obj/machinery/icts/proc/detailed_destination_list(specific_transport_id)
	. = list()
	for(var/obj/effect/landmark/icts/nav_beacon/tram/destination as anything in SSicts_transport.nav_beacons[specific_transport_id])
		var/list/this_destination = list()
		this_destination["name"] = destination.name
		this_destination["dest_icons"] = destination.tgui_icons
		this_destination["id"] = destination.platform_code
		. += list(this_destination)
