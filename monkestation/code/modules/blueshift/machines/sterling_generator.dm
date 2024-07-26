///To be used when there is the need of an atmos connection without repathing everything (eg: cryo.dm)
/datum/gas_machine_connector

	var/obj/machinery/connected_machine
	var/obj/machinery/atmospherics/components/unary/gas_connector

/datum/gas_machine_connector/New(location, obj/machinery/connecting_machine = null, direction = SOUTH, gas_volume)
	connected_machine = connecting_machine
	if(!connected_machine)
		qdel(src)
		return

	gas_connector = new(location)
	gas_connector.dir = connected_machine.dir
	gas_connector.airs[1].volume = gas_volume

	SSair.start_processing_machine(connected_machine)
	register_with_machine()
	gas_connector.set_init_directions()
	gas_connector.atmos_init()
	SSair.add_to_rebuild_queue(gas_connector)
	RegisterSignal(gas_connector, COMSIG_QDELETING, PROC_REF(connector_deleted))

/datum/gas_machine_connector/Destroy()
	connected_machine = null
	QDEL_NULL(gas_connector)
	return ..()

/datum/gas_machine_connector/proc/connector_deleted()
	SIGNAL_HANDLER
	gas_connector = null
	if(!QDELETED(connected_machine))
		qdel(connected_machine)

/**
 * Register various signals that are required for the proper work of the connector
 */
/datum/gas_machine_connector/proc/register_with_machine()
	RegisterSignal(connected_machine, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(pre_move_connected_machine))
	RegisterSignal(connected_machine, COMSIG_MOVABLE_MOVED, PROC_REF(moved_connected_machine))
	RegisterSignal(connected_machine, COMSIG_MACHINERY_DEFAULT_ROTATE_WRENCH, PROC_REF(wrenched_connected_machine))
	RegisterSignal(connected_machine, COMSIG_OBJ_DECONSTRUCT, PROC_REF(deconstruct_connected_machine))
	RegisterSignal(connected_machine, COMSIG_QDELETING, PROC_REF(destroy_connected_machine))

/**
 * Unregister the signals previously registered
 */
/datum/gas_machine_connector/proc/unregister_from_machine()
	UnregisterSignal(connected_machine, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOVABLE_PRE_MOVE,
		COMSIG_MACHINERY_DEFAULT_ROTATE_WRENCH,
		COMSIG_OBJ_DECONSTRUCT,
		COMSIG_QDELETING
	))

/**
 * Called when the machine has been moved, reconnect to the pipe network
 */
/datum/gas_machine_connector/proc/moved_connected_machine()
	SIGNAL_HANDLER
	gas_connector.forceMove(get_turf(connected_machine))
	reconnect_connector()

/**
 * Called before the machine moves, disconnect from the pipe network
 */
/datum/gas_machine_connector/proc/pre_move_connected_machine()
	SIGNAL_HANDLER
	disconnect_connector()

/**
 * Called when the machine has been rotated, resets the connection to the pipe network with the new direction
 */
/datum/gas_machine_connector/proc/wrenched_connected_machine()
	SIGNAL_HANDLER
	disconnect_connector()
	reconnect_connector()

/**
 * Called when the machine has been deconstructed
 */
/datum/gas_machine_connector/proc/deconstruct_connected_machine()
	SIGNAL_HANDLER

	relocate_airs()

/**
 * Called when the machine has been destroyed
 */
/datum/gas_machine_connector/proc/destroy_connected_machine()
	SIGNAL_HANDLER

	disconnect_connector()
	SSair.stop_processing_machine(connected_machine)
	unregister_from_machine()
	qdel(src)

/**
 * Handles the disconnection from the pipe network
 */
/datum/gas_machine_connector/proc/disconnect_connector()
	var/obj/machinery/atmospherics/node = gas_connector.nodes[1]
	if(node)
		if(gas_connector in node.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node.disconnect(gas_connector)
		gas_connector.nodes[1] = null
	if(gas_connector.parents[1])
		gas_connector.nullify_pipenet(gas_connector.parents[1])

/**
 * Handles the reconnection to the pipe network
 */
/datum/gas_machine_connector/proc/reconnect_connector()
	gas_connector.dir = connected_machine.dir
	gas_connector.set_init_directions()
	var/obj/machinery/atmospherics/node = gas_connector.nodes[1]
	gas_connector.atmos_init()
	node = gas_connector.nodes[1]
	if(node)
		node.atmos_init()
		node.add_member(gas_connector)
		gas_connector.update_parents()
	SSair.add_to_rebuild_queue(gas_connector)

/**
 * Handles air relocation to the pipe network/environment
 */
/datum/gas_machine_connector/proc/relocate_airs(mob/user)
	var/turf/local_turf = get_turf(connected_machine)
	var/datum/gas_mixture/inside_air = gas_connector.airs[1]
	if(inside_air.total_moles() > 0)
		if(!gas_connector.nodes[1])
			local_turf.assume_air(inside_air)
			return
		var/datum/gas_mixture/parents_air = gas_connector.parents[1].air
		if(istype(gas_connector.nodes[1], /obj/machinery/atmospherics/components/unary/portables_connector))
			var/obj/machinery/atmospherics/components/unary/portables_connector/portable_devices_connector = gas_connector.nodes[1]
			if(!portable_devices_connector.connected_device)
				local_turf.assume_air(inside_air)
				return
		parents_air.merge(inside_air)

// Stirling generator, like a miniature TEG, pipe hot air in, and keep the air around it cold

/obj/machinery/power/stirling_generator
	name = "stirling generator"
	desc = "An industrial scale stirling generator. Stirling generators operate by intaking \
		hot gasses through their inlet pipes, and being cooled by the ambient air around them. \
		The cycling compression and expansion caused by this creates power, and this one is made \
		to make power on the scale of small stations and outposts."
	icon = 'monkestation/code/modules/blueshift/icons/stirling_generator/big_generator.dmi'
	icon_state = "stirling"
	density = TRUE
	use_power = NO_POWER_USE
	circuit = null
	max_integrity = 300
	armor_type = /datum/armor/unary_thermomachine
	set_dir_on_move = FALSE
	can_change_cable_layer = TRUE
	/// Reference to the datum connector we're using to interface with the pipe network
	var/datum/gas_machine_connector/connected_chamber
	/// What this thing deconstructs into
	var/deconstruction_type = /obj/item/flatpacked_machine/stirling_generator
	/// Maximum efficient heat difference, at what heat difference does more difference stop meaning anything for power?
	var/max_efficient_heat_difference = 8000
	/// Maximum power output from this machine
	var/max_power_output = 100 * 10 KW
	/// How much power the generator is currently making
	var/current_power_generation
	/// Our looping fan sound that we play when turned on
	var/datum/looping_sound/ore_thumper_fan/soundloop


/obj/machinery/power/stirling_generator/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)
	connected_chamber = new(loc, src, dir, CELL_VOLUME * 0.5)
	connect_to_network()
	AddElement(/datum/element/repackable, deconstruction_type, 10 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)
	// This is just to make sure our atmos connection spawns facing the right way
	setDir(dir)


/obj/machinery/power/stirling_generator/examine(mob/user)
	. = ..()
	. += span_notice("You can use a <b>wrench</b> with <b>Left-Click</b> to rotate the generator.")
	. += span_notice("It will not work in a <b>vacuum</b> as it must be cooled by the gas around it.")
	. += span_notice("It is currently generating <b>[current_power_generation / 1000] kW</b> of power.")
	. += span_notice("It has a maximum power output of <b>[max_power_output / 1000] kW</b> at a temperature difference of <b>[max_efficient_heat_difference] K</b>.")


/obj/machinery/power/stirling_generator/Destroy()
	QDEL_NULL(connected_chamber)
	return ..()


/obj/machinery/power/stirling_generator/process_atmos()
	if(!powernet)
		connect_to_network()
		if(!powernet)
			return

	var/turf/our_turf = get_turf(src)

	var/datum/gas_mixture/hot_air_from_pipe = connected_chamber.gas_connector.airs[1]
	var/datum/gas_mixture/environment = our_turf.return_air()

	if(!QUANTIZE(hot_air_from_pipe.total_moles()) || !QUANTIZE(environment.total_moles())) //Don't transfer if there's no gas
		return

	var/gas_temperature_delta = hot_air_from_pipe.temperature - environment.temperature

	if(!(gas_temperature_delta > 0))
		current_power_generation = 0
		return

	var/input_capacity = hot_air_from_pipe.heat_capacity()
	var/output_capacity = environment.heat_capacity()
	var/cooling_heat_amount = CALCULATE_CONDUCTION_ENERGY(gas_temperature_delta, input_capacity, output_capacity)
	hot_air_from_pipe.temperature = max(hot_air_from_pipe.temperature - (cooling_heat_amount / input_capacity), TCMB)

	/// Takes the amount of heat moved, and divides it by the maximum temperature difference we expect, creating a number to divide power generation by
	var/effective_energy_transfer = round((max_efficient_heat_difference / min(gas_temperature_delta, max_efficient_heat_difference)), 0.01)
	current_power_generation = round(max_power_output / effective_energy_transfer)


/obj/machinery/power/stirling_generator/process()
	var/power_output = round(current_power_generation)
	add_avail(power_output)
	var/new_icon_state = (power_output ? "stirling_on" : "stirling")
	icon_state = new_icon_state
	if(soundloop.is_active() && !power_output)
		soundloop.stop()
	else if(!soundloop.is_active() && power_output)
		soundloop.start()


/obj/machinery/power/stirling_generator/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return


/obj/machinery/power/stirling_generator/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return


/obj/machinery/power/stirling_generator/wrench_act(mob/living/user, obj/item/tool)
	return default_change_direction_wrench(user, tool)


/obj/machinery/power/stirling_generator/default_change_direction_wrench(mob/user, obj/item/wrench)
	if(wrench.tool_behaviour != TOOL_WRENCH)
		return FALSE

	wrench.play_tool_sound(src, 50)
	setDir(turn(dir,-90))
	to_chat(user, span_notice("You rotate [src]."))
	SEND_SIGNAL(src, COMSIG_MACHINERY_DEFAULT_ROTATE_WRENCH, user, wrench)
	return TRUE


/obj/machinery/power/stirling_generator/Destroy()
	QDEL_NULL(connected_chamber)
	return ..()


// Item for creating stirling generators

/obj/item/flatpacked_machine/stirling_generator
	name = "flat-packed stirling generator"
	icon = 'monkestation/code/modules/blueshift/icons/stirling_generator/packed_machines.dmi'
	icon_state = "stirling"
	type_to_deploy = /obj/machinery/power/stirling_generator
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 15,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/plasma = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 5,
	)
