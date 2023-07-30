/obj/machinery/icts
	var/list/methods_to_fix = list()
	var/list/repair_signals

/**
 * All ICTS subtypes have the same method of repair for consistency and predictability
 * The key of this assoc list is the "method" of how they're fixing the thing (just flavor for examine),
 * and the value is what tool they actually need to use on the thing to fix it
 */
/obj/machinery/icts/proc/generate_repair_signals(steps)
	var/list/how_do_we_fix_it = list(
		"try turning it off and on again" = TOOL_MULTITOOL,
		"forcing an unexpected reboot" = TOOL_MULTITOOL,
		"patch the system's call table" = TOOL_MULTITOOL,
		"gently reset the invalid memory" = TOOL_CROWBAR,
		"securing its ground connection" = TOOL_WRENCH,
		"tightening some screws" = TOOL_SCREWDRIVER,
		"checking its wire voltages" = TOOL_MULTITOOL,
		"cutting some excess wires" = TOOL_WIRECUTTER,
	)
	var/list/fix_it_keys = assoc_to_keys(how_do_we_fix_it)

	// Select a few methods of how to fix it
	var/list/methods_to_fix = list()
	for(var/i in 1 to steps)
		methods_to_fix += pick_n_take(fix_it_keys)

	// Construct the signals
	LAZYINITLIST(repair_signals)
	for(var/tool_method in methods_to_fix)
		repair_signals += COMSIG_ATOM_TOOL_ACT(how_do_we_fix_it[tool_method])

	// Register signals to make it fixable
	if(length(repair_signals))
		RegisterSignals(src, repair_signals, PROC_REF(on_machine_tooled))

/obj/machinery/icts/proc/clear_repair_signals()
	if(length(repair_signals))
		for(var/signal in repair_signals)
			UnregisterSignal(src, repair_signals)
			LAZYREMOVE(repair_signals, signal)

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
/obj/machinery/icts/proc/try_fix_machine(obj/machinery/source, mob/living/user, obj/item/tool)
	source.balloon_alert(user, "percussive maintenance...")
	// Fairly long do after. It shouldn't be SUPER easy to just run in and stop it.
	// A tider can fix it if they want to soak a bunch of rads and inhale noxious fumes,
	// but only an equipped engineer should be able to handle it painlessly.
	if(!tool.use_tool(source, user, 7 SECONDS, volume = 50))
		source.balloon_alert(user, "interrupted!")
		return

	source.balloon_alert(user, "repair success")
