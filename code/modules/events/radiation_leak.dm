/datum/round_event_control/radiation_leak
	name = "Radiation Leak"
	description = "A radiation leak happens somewhere on the station, emanating radiation around a machine in the area. \
		Engineering can stop the leak by using certain tools on it."
	typepath = /datum/round_event/radiation_leak
	weight = 15
	max_occurrences = 3
	category = EVENT_CATEGORY_ENGINEERING
	min_wizard_trigger_potency = 3
	max_wizard_trigger_potency = 7

/datum/round_event/radiation_leak
	start_when = 1 // 2 seconds in
	announce_when = 10 // 20 seconds in
	end_when = 150 // 300 seconds / ~5 minutes in

	/// Weakref to the machine spitting out rads
	var/datum/weakref/picked_machine_ref
	/// List of signals added to the picked machine, so we can clear them later
	var/list/signals_to_add

/datum/round_event/radiation_leak/setup()
	// Pick a generic event spawn somewhere in the world.
	// We will try to find a machine within a few turfs of it to start spewing rads from.
	var/list/possible_locs = GLOB.generic_event_spawns.Copy()
	while(length(possible_locs))
		var/turf/chosen_loc = get_turf(pick_n_take(possible_locs))
		for(var/obj/machinery/sick_device in range(3, chosen_loc))
			// Excludes machines that don't use power, as these are usually non-machine machinery
			if(sick_device.use_power == NO_POWER_USE)
				continue
			// Look for dense machinery. Basically stops stuff like wall mounts and pipes, silly ones.
			// But keep in vents and scrubbers. I think it's funny if they start spitting out radiation
			if(!sick_device.density && !istype(sick_device, /obj/machinery/atmospherics/components/unary))
				continue
			// Skip invisible stuff
			if(sick_device.invisibility || !sick_device.alpha || !sick_device.mouse_opacity)
				continue
			// Skip undertiles
			if(sick_device.IsObscured())
				continue
			// Very basic check for atmos passability here
			// We don't want to put our smoke inside something that can't spread it out, like airlocks
			if(sick_device.can_atmos_pass() != ATMOS_PASS_YES)
				continue

			// We found something, we can just return now
			picked_machine_ref = WEAKREF(sick_device)
			return

/datum/round_event/radiation_leak/announce(fake)
	var/obj/machinery/the_source_of_our_problems = picked_machine_ref?.resolve()
	var/area/station/location_descriptor

	if(fake)
		location_descriptor = GLOB.areas_by_type[pick(GLOB.the_station_areas)]

	else if(the_source_of_our_problems)
		location_descriptor = get_area(the_source_of_our_problems)

	priority_announce("A radiation leak has been detected in [location_descriptor || "an unknown area"]. \
		All crew are to evacuate the affected area. Our [pick("mechanics", "engineers", "scientists", "interns", "sensors", "readings")] \
		report that a machine within is causing it - repair it quickly to stop the leak.", "[command_name()] Engineering Division")

/datum/round_event/radiation_leak/start()
	var/obj/machinery/the_source_of_our_problems = picked_machine_ref?.resolve()
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
	var/list/fix_it_keys = assoc_to_keys(how_do_we_fix_it) // Returns a copy that we can pick and take from, fortunately

	// Select a few methods of how to fix it
	var/list/methods_to_fix = list()
	for(var/i in 1 to rand(1, 3))
		methods_to_fix += pick_n_take(fix_it_keys)

	// Construct the signals
	signals_to_add = list()
	for(var/tool_method in methods_to_fix)
		signals_to_add += COMSIG_ATOM_TOOL_ACT(how_do_we_fix_it[tool_method])

	the_source_of_our_problems.visible_message(span_danger("[the_source_of_our_problems] starts to emanate a horrible green gas!"))
	// Add the component that makes the thing radioactive
	the_source_of_our_problems.AddComponent(
		/datum/component/radioactive_emitter, \
		cooldown_time = 2 SECONDS, \
		range = 5, \
		threshold = RAD_MEDIUM_INSULATION, \
		examine_text = span_green("<i>It's emanating a green gas... You could probably stop it by [english_list(methods_to_fix, and_text = " or ")].</i>"), \
	)
	// Register signals to make it fixable
	if(length(signals_to_add))
		RegisterSignals(the_source_of_our_problems, signals_to_add, PROC_REF(on_machine_tooled))

	// And yknow puffs some nasty reagents into the air, just to seal the deal
	puff_some_smoke(the_source_of_our_problems)
	// Let ghosts know
	announce_to_ghosts(the_source_of_our_problems)

/datum/round_event/radiation_leak/tick()
	// Puff some smoke into the air around our machine roughly 3 times before we stop
	if(activeFor % (end_when / 3) != 0)
		return

	var/obj/machinery/impromptu_smoke_machine = picked_machine_ref?.resolve()
	if(!impromptu_smoke_machine)
		return

	puff_some_smoke(impromptu_smoke_machine)

/datum/round_event/radiation_leak/end()
	var/obj/machinery/the_end_of_our_problems = picked_machine_ref?.resolve()
	if(!the_end_of_our_problems)
		return

	the_end_of_our_problems.visible_message(span_notice("The gas emanating from [the_end_of_our_problems] dissipates."))
	qdel(the_end_of_our_problems.GetComponent(/datum/component/radioactive_emitter))
	if(length(signals_to_add))
		UnregisterSignal(the_end_of_our_problems, signals_to_add)
	picked_machine_ref = null
	signals_to_add = null

/// Helper to shoot some smoke into the air around the passed atom
/datum/round_event/radiation_leak/proc/puff_some_smoke(atom/where)
	var/turf/below_where = get_turf(where)
	var/datum/effect_system/fluid_spread/smoke/chem/gross_smoke = new()
	gross_smoke.chemholder.add_reagent(/datum/reagent/toxin/polonium, 10) // Polonium (it causes radiation)
	gross_smoke.chemholder.add_reagent(/datum/reagent/toxin/mutagen, 10) // Mutagen (it causes mutations. Also it's green... Primarily because it's green.)
	gross_smoke.attach(below_where)
	gross_smoke.set_up(2, holder = where, location = below_where, silent = TRUE)
	gross_smoke.start()
	playsound(below_where, 'sound/effects/smoke.ogg', 50, vary = TRUE)

/**
 * Signal proc for [COMSIG_ATOM_TOOL_ACT], from a variety of signals, registered on the machine spitting radiation
 *
 * We allow for someone to stop the event early by using the proper tools, hinted at in examine, on the machine
 */
/datum/round_event/radiation_leak/proc/on_machine_tooled(obj/machinery/source, mob/living/user, obj/item/tool)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(try_remove_radiation), source, user, tool)
	return ITEM_INTERACT_BLOCKING

/// Attempts a do_after, and if successful, stops the event
/datum/round_event/radiation_leak/proc/try_remove_radiation(obj/machinery/source, mob/living/user, obj/item/tool)
	source.balloon_alert(user, "fixing leak...")
	// Fairly long do after. It shouldn't be SUPER easy to just run in and stop it.
	// A tider can fix it if they want to soak a bunch of rads and inhale noxious fumes,
	// but only an equipped engineer should be able to handle it painlessly.
	if(!tool.use_tool(source, user, 30 SECONDS, amount = (tool.tool_behaviour == TOOL_WELDER ? 2 : 0), volume = 50))
		source.balloon_alert(user, "interrupted!")
		return

	source.balloon_alert(user, "leak repaired")
	// Force end the event
	processing = FALSE
	end()
	kill()
