/obj/machinery/atmospherics/fueled_engine_heater
	name = "Fueled Engine Heater"
	desc = "A small heater that is designed to contain a combustible gas for it's connected engine."
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "heater"
	pipe_flags = PIPING_ALL_COLORS | PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	device_type = UNARY

	/// The engine that this heater is connected to
	var/obj/machinery/power/shuttle_engine/ship/fueled/connected_engine

	var/datum/gas_mixture/air_contents

	/// The volume of the internal tank for this heater
	var/internal_volume = 1000

	/// The absolute maximum number of moles this heater can hold
	var/maximum_moles = 1000

	/// The rate the internal tank will be refilled, in percentage of maximum moles
	var/recharge_speed = 0.05

	/// The rate at which incompatible fuels will be filtered out, in percentage of total mole count of the incompatible gas
	var/filter_rate = 0.01

	/// If purge mode is active the heater will purge the internal tank instead of filtering it
	var/purge_mode = FALSE

	/// Whether this heater will draw in air from the connected pipe
	var/input_enabled = TRUE

	/// Whether this heater will filter out incompatible gases from the internal tank
	var/filter_enabled = TRUE

/obj/machinery/atmospherics/fueled_engine_heater/Initialize(mapload)
	air_contents = new(internal_volume)
	. = ..()
	register_context()

/obj/machinery/atmospherics/fueled_engine_heater/LateInitialize()
	. = ..()
	try_link_engine()

/obj/machinery/atmospherics/fueled_engine_heater/proc/try_link_engine()
	SHOULD_NOT_OVERRIDE(TRUE)
	if(connected_engine)
		return

	var/turf/candidate_turf = get_step(src, dir)
	var/obj/machinery/power/shuttle_engine/ship/fueled/candidate_engine = locate() in candidate_turf
	if(!candidate_engine || candidate_engine.dir != turn(dir, 180))
		return
	on_engine_link(candidate_engine)

/// Called when the engine is linked to a heater; must call parent first.
/obj/machinery/atmospherics/fueled_engine_heater/proc/on_engine_link(obj/machinery/power/shuttle_engine/ship/fueled/connecting)
	SHOULD_CALL_PARENT(TRUE)
	if(connected_engine == connecting)
		return
	if(connected_engine)
		on_engine_unlink()

	SSair.start_processing_machine(src)
	connected_engine = connecting
	connected_engine.connected_heater = src
	name = "[initial(name)] ([connected_engine.fuel_type:name])"

/// Called when the engine is unlinked from a heater; must call parent first.
/obj/machinery/atmospherics/fueled_engine_heater/proc/on_engine_unlink()
	SHOULD_CALL_PARENT(TRUE)
	if(!connected_engine)
		return

	SSair.stop_processing_machine(src)
	connected_engine.connected_heater = null
	connected_engine = null
	input_enabled = FALSE
	name = initial(name)

/obj/machinery/atmospherics/fueled_engine_heater/Destroy()
	if(connected_engine)
		on_engine_unlink()
	return ..()

/obj/machinery/atmospherics/fueled_engine_heater/is_connectable(obj/machinery/atmospherics/target, given_layer)
	if(get_dir(src, target) != turn(dir, 180))
		return FALSE
	return ..()

/obj/machinery/atmospherics/fueled_engine_heater/proc/get_dump_air_mixture()
	RETURN_TYPE(/datum/gas_mixture)

	if(length(nodes) && nodes[1])
		var/obj/machinery/atmospherics/node = nodes[1]
		return node.return_air()
	return loc.return_air()

/obj/machinery/atmospherics/fueled_engine_heater/proc/dump_air_contents()
	var/datum/gas_mixture/dump_into = get_dump_air_mixture()
	dump_into.merge(air_contents.remove_ratio(1))

/obj/machinery/atmospherics/fueled_engine_heater/proc/filter_air_contents()
	var/datum/gas_mixture/dump_into = get_dump_air_mixture()
	if(purge_mode)
		var/purge_ratio = filter_rate * 10
		dump_into.merge(air_contents.remove_ratio(purge_ratio))
		return

	if(!connected_engine.fuel_type)
		return

	var/datum/gas_mixture/filtered = air_contents.remove_ratio(filter_rate)
	filtered.assert_gas(connected_engine.fuel_type)
	var/datum/gas_mixture/compatible = filtered.remove_specific(connected_engine.fuel_type, INFINITY)
	dump_into.merge(filtered)
	air_contents.merge(compatible)

/obj/machinery/atmospherics/fueled_engine_heater/proc/input_air_contents()
	if(!length(nodes) || !nodes[1])
		return

	var/obj/machinery/atmospherics/node = nodes[1]
	var/datum/gas_mixture/input = node.return_air()
	if(!input)
		return

	var/datum/gas_mixture/removed = input.remove_ratio(recharge_speed)
	air_contents.merge(removed)

/obj/machinery/atmospherics/fueled_engine_heater/process_atmos()
	if(!connected_engine)
		return PROCESS_KILL

	if(input_enabled)
		input_air_contents()

	if(filter_enabled)
		filter_air_contents()

/obj/machinery/atmospherics/fueled_engine_heater/deconstruct(disassembled)
	if(!disassembled) // if it was destroyed dump into the local atmosphere
		var/list/old_nodes = nodes
		nodes = null
		dump_air_contents()
		nodes = old_nodes
	else
		dump_air_contents()

	return ..()

/obj/machinery/atmospherics/fueled_engine_heater/screwdriver_act(mob/living/user, obj/item/tool)
	var/initial = initial(icon_state)
	if(default_deconstruction_screwdriver(user, "[initial]_open", initial, tool))
		return TRUE

/obj/machinery/atmospherics/fueled_engine_heater/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_deconstruction_crowbar(tool))
		return TRUE

/obj/machinery/atmospherics/fueled_engine_heater/multitool_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		return FALSE

	input_enabled = !input_enabled
	to_chat(user, span_notice("You [input_enabled ? "enable" : "disable"] filtering."))

/obj/machinery/atmospherics/fueled_engine_heater/multitool_act_secondary(mob/living/user, obj/item/tool)
	if(!panel_open)
		return FALSE

	purge_mode = !purge_mode
	to_chat(user, span_notice("You [purge_mode ? "enable" : "disable"] purge mode."))
	return TRUE

/obj/machinery/atmospherics/fueled_engine_heater/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(panel_open)
		switch(held_item.tool_behaviour)
			if(TOOL_MULTITOOL)
				context[SCREENTIP_CONTEXT_LMB] = "Toggle Filtering"
				context[SCREENTIP_CONTEXT_RMB] = "Toggle Purge Mode"
			if(TOOL_SCREWDRIVER)
				context[SCREENTIP_CONTEXT_LMB] = "Close Panel"
			if(TOOL_CROWBAR)
				context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
	else
		if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_LMB] = "Open Panel"
	return CONTEXTUAL_SCREENTIP_SET
