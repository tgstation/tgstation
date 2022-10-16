/datum/round_event_control/radiation_leak
	name = "Radiation Leak"
	description = "A radiation leak happens somewhere on the station, emanating radiation around a machine in the area. \
		Engineering can stop the leak by using certain tools on it."
	typepath = /datum/round_event/radiation_leak
	weight = 15
	max_occurrences = 2
	category = EVENT_CATEGORY_ENGINEERING

/datum/round_event/radiation_leak
	start_when = 1 // 2 seconds in
	announce_when = 10 // 20 seconds in
	end_when = 150 // 300 seconds / ~5 minutes in

	var/datum/weakref/picked_machine

/datum/round_event/radiation_leak/setup()
	// Pick a xeno spawn somewhere in the world.
	// We will try to find a machine within a few turfs of it to start spewing rads from.
	var/list/possible_locs = GLOB.generic_event_spawns.Copy()
	while(length(possible_locs))
		var/turf/chosen_loc = get_turf(pick_n_take(possible_locs))
		for(var/obj/machinery/sick_device in range(3, chosen_loc))
			// Skip undertiles
			if(sick_device.IsObscured())
				continue
			// Skip invisible stuff
			if(sick_device.invisibility || !sick_device.alpha || !sick_device.mouse_opacity)
				continue
			// Look for dense machinery. Basically stops stuff like wall mounts and pipes, silly ones.
			// But keep in vents and scrubbers. I think it's funny if they start spitting out radiation
			if(!sick_device.density && !istype(sick_device, /obj/machinery/atmospherics/components/unary))
				continue

			// We found something, we can just return now
			picked_machine = WEAKREF(sick_device)
			return

/datum/round_event/radiation_leak/announce(fake)
	var/obj/machinery/the_source_of_our_problems = picked_machine?.resolve()
	var/location_descriptor

	if(fake)
		location_descriptor = get_area_name(pick(GLOB.the_station_areas))

	else if(the_source_of_our_problems)
		location_descriptor = get_area_name(the_source_of_our_problems)

	priority_announce("Radiation leak has been detected in: [location_descriptor || "An unknown area"]. \
		All crew are to evacuate the affected area. Our mechanics report that a machine within is causing it - \
		repair it quickly to stop the leak.")

/datum/round_event/radiation_leak/start()
	var/obj/machinery/the_source_of_our_problems = picked_machine?.resolve()
	if(!the_source_of_our_problems)
		return

	// We'll add some tool acts to the thing that allow people to "repair the machine"
	// The key of this assoc list is the "method" of how they're fixing the thing (just flavor for examine),
	// and the value is what tool they actually need to use on the thing to fix it
	var/list/how_do_we_fix_it = list(
		"wrenching a few valves" = TOOL_WRENCH,
		"tightening its bolts" = TOOL_WRENCH,
		"crowbaring its panel [pick("down", "up")]" = TOOL_CROWBAR,
		"tightening some screws" = TOOL_SCREWDRIVER,
		"checking its [pick("wires", "circuits")]" = TOOL_MULTITOOL,
		"welding its panel [pick("open", "shut")]" = TOOL_WELDER,
		"analyzing its readings" = TOOL_ANALYZER,
		"cutting some excess wires" = TOOL_WIRECUTTER,
	)
	var/list/fix_it_keys = assoc_to_keys(how_do_we_fix_it) // Returns a copy that we can pick and take, fortunately

	// Select a few methods of how to fix it
	var/list/methods_to_fix = list()
	for(var/i in 1 to rand(1, 3))
		methods_to_fix += pick_n_take(fix_it_keys)

	// Construct the signals
	var/list/signals_to_add = list()
	for(var/tool_method in methods_to_fix)
		signals_to_add += COMSIG_ATOM_TOOL_ACT(how_do_we_fix_it[tool_method])

	the_source_of_our_problems.visible_message(span_danger("[the_source_of_our_problems] starts to emanate a horrible green gas!"))
	// Add the component that makes the thing radioactive
	the_source_of_our_problems.AddComponent(/datum/component/radioactive_emitter, \
		cooldown_time = 2 SECONDS, \
		range = 5, \
		threshold = RAD_MEDIUM_INSULATION, \
		examine_text = span_green("<i>It's emanating a green gas... You could probably stop it by [english_list(methods_to_fix, and_text = " or ")].</i>"), \
		signals_which_delete_us = signals_to_add, \
		sigreturn = COMPONENT_BLOCK_TOOL_ATTACK, \
		on_signal_callback = CALLBACK(src, .proc/on_tool), \
	)

	// And yknow puffs some nasty reagents into the air, just to seal the deal
	puff_some_smoke(the_source_of_our_problems)
	// Let ghosts know
	announce_to_ghosts(the_source_of_our_problems)

/datum/round_event/radiation_leak/tick()
	// Puff some smoke into the air around our machine roughly 3 times before we stop
	if(activeFor % (end_when / 3) != 0)
		return

	var/obj/machinery/impromptu_smoke_machine = picked_machine?.resolve()
	if(!impromptu_smoke_machine)
		return

	puff_some_smoke(impromptu_smoke_machine)

/datum/round_event/radiation_leak/end()
	var/obj/machinery/the_end_of_our_problems = picked_machine?.resolve()
	if(!the_end_of_our_problems)
		return

	the_end_of_our_problems.visible_message(span_notice("The gas emanating from [the_end_of_our_problems] dissipates."))
	qdel(the_end_of_our_problems.GetComponent(/datum/component/radioactive_emitter))
	picked_machine = null

/// Helper to shoot some smoke into the air around the passed atom
/datum/round_event/radiation_leak/proc/puff_some_smoke(atom/where)
	var/turf/below_where = get_turf(where)
	var/datum/effect_system/fluid_spread/smoke/chem/gross_smoke = new()
	gross_smoke.chemholder.add_reagent(/datum/reagent/toxin/polonium, 10) // Polonium (it causes radiation)
	gross_smoke.chemholder.add_reagent(/datum/reagent/toxin/mutagen, 10) // Mutagen (it causes mutations. Also it's green... Primarily because it's green.)
	gross_smoke.attach(below_where)
	gross_smoke.set_up(2, holder = where, location = below_where, silent = TRUE)
	gross_smoke.start()

/// Callback for the emitter component to allow us to "tool" the emitter to "fix" it
/datum/round_event/radiation_leak/proc/on_tool(obj/machinery/source, mob/living/user, obj/item/tool)
	source.balloon_alert(user, "fixing leak...")
	tool.play_tool_sound(source)
	if(!do_after(user, 6 SECONDS, source))
		source.balloon_alert(user, "interrupted!")
		return FALSE

	// we'll qdel after we return, play the ballon at loc instead
	source.loc.balloon_alert(user, "leak fixed")
	tool.play_tool_sound(source)
	return TRUE
