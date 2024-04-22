#define DAMAGED_LUBRICANT_SYSTEM (1<<0)

//node2, air2, network2 correspond to input
//node1, air1, network1 correspond to output

/obj/machinery/atmospherics/components/binary/circulator
	name = "circulator/heat exchanger"
	desc = "A gas circulator pump and heat exchanger."
	icon = 'goon/icons/teg.dmi'
	icon_state = "circ1-off"
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	vent_movement = VENTCRAWL_CAN_SEE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/circulator

	var/active = FALSE
	var/last_pressure_delta = 0
	var/flipped = 0
	///Which circulator mode we are on, the generator requires one of each to work.
	var/mode = CIRCULATOR_HOT
	///The generator we are connected to.
	var/obj/machinery/power/thermoelectric_generator/generator

	///our reagent buffer
	var/reagent_buffer = 400
	///our list of reagents and how good they are as lubricant (this is independant of viscosity as it can be changed by teg states)
	var/list/liked_lubricants = list(
		/datum/reagent/fuel/oil = 1,
		/datum/reagent/lube = 1.2,
		/datum/reagent/lube/superlube = 1.4
	)
	///our list of bad reagents (these damage the lubrication system)
	var/list/bad_reagents = list(
		/datum/reagent/toxin/acid = 10,
		/datum/reagent/toxin/acid/fluacid = 10,
		/datum/reagent/toxin/acid/nitracid = 10,
	)
	///our lubrication multiplier
	var/lubricated_multiplier = 1
	///our current circulator flags
	var/circulator_flags = NONE
	///this is the amount of reagent loss we have per lube check
	var/lubricant_loss = 0
	///process count for lube checks (maybe timer in the future?)
	var/lube_processes = 0
	///how many lube processes we have left
	var/lube_process_count = 0

/obj/machinery/atmospherics/components/binary/circulator/Initialize(mapload)
	. = ..()
	create_reagents(reagent_buffer)
	RegisterSignals(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT), PROC_REF(on_reagent_change))
	reagents.add_reagent(/datum/reagent/fuel/oil, 200)

//default cold circ for mappers
/obj/machinery/atmospherics/components/binary/circulator/cold
	icon_state = "circ2-off"
	flipped = 1
	mode = CIRCULATOR_COLD

/obj/machinery/atmospherics/components/binary/circulator/Destroy()
	if(generator)
		disconnectFromGenerator()
	return ..()

/obj/machinery/atmospherics/components/binary/circulator/proc/on_reagent_change(datum/reagents/incoming_reagents, ...)
	var/recalculated_lubricant_multiplier = 0

	if(!reagents.total_volume)
		recalculated_lubricant_multiplier = 0.5
	else
		for(var/datum/reagent/reagent as anything in reagents.reagent_list)
			if(reagent.type in liked_lubricants)
				recalculated_lubricant_multiplier += (reagent.volume / reagents.total_volume) * liked_lubricants[reagent.type]
			else
				recalculated_lubricant_multiplier += (reagent.volume / reagents.total_volume) * (0.2 * reagent.viscosity + 0.75)
	lubricated_multiplier = recalculated_lubricant_multiplier


/obj/machinery/atmospherics/components/binary/circulator/proc/return_transfer_air()

	var/datum/gas_mixture/air1 = airs[1]
	var/datum/gas_mixture/air2 = airs[2]

	var/output_starting_pressure = air1.return_pressure()
	var/input_starting_pressure = air2.return_pressure()

	if(output_starting_pressure >= input_starting_pressure-10)
		//Need at least 10 KPa difference to overcome friction in the mechanism
		last_pressure_delta = 0
		return null

	//Calculate necessary moles to transfer using PV = nRT
	if(air2.temperature <= 0)
		last_pressure_delta = 0
		return

	var/pressure_delta = (input_starting_pressure - output_starting_pressure)/2
	pressure_delta *= lubricated_multiplier

	var/transfer_moles = abs(pressure_delta) * air1.volume / max(air2.temperature / R_IDEAL_GAS_EQUATION, 1) //this fixes a runtime where because of weirdness we runtime as pressure delta is negative so we abs() it
	last_pressure_delta = pressure_delta
	//Actually transfer the gas
	var/datum/gas_mixture/removed = air2.remove(transfer_moles)
	reagent_effects(removed)
	update_parents()
	return removed

/obj/machinery/atmospherics/components/binary/circulator/proc/reagent_effects(datum/gas_mixture/removed)
	if(!reagents.total_volume)
		return

	var/temperature_change = 0

	if(!(circulator_flags & DAMAGED_LUBRICANT_SYSTEM)) //if we aren't damaged check our lubricant storage for bad lubricants
		var/total_reagents = 0
		for(var/datum/reagent/reagent as anything in reagents.reagent_list)
			if(!(reagent.type in bad_reagents))
				continue
			if(reagent.volume >= bad_reagents[reagent.type])
				total_reagents += reagent.volume
		if(total_reagents && prob(10 * (total_reagents * 0.1))) //100 units of reagents will surely break your shit
			circulator_flags |= DAMAGED_LUBRICANT_SYSTEM
			lubricant_loss = reagent_buffer * 0.2
			lube_processes = 1

	if(!removed)
		return

	for(var/datum/reagent/reagent as anything in reagents.reagent_list)
		reagent.circulator_process(src, removed)

	if(reagents.has_reagent(/datum/reagent/cryostylane))
		temperature_change -= 200
		if(prob(3))
			visible_message(span_warning("You notice a thin layer of frost form on the [src]!"))

	if(reagents.has_reagent(/datum/reagent/pyrosium))
		temperature_change += 200
		if(prob(3))
			visible_message(span_warning("You notice the [src] looks to be briefly covered in haze!"))

	removed.temperature = max(removed.temperature + temperature_change, 1)

/obj/machinery/atmospherics/components/binary/circulator/process_atmos()
	update_appearance()

/obj/machinery/atmospherics/components/binary/circulator/update_icon_state()
	if(!is_operational)
		icon_state = "circ[flipped+1]-p"
		return ..()
	if(last_pressure_delta > 0)
		if(last_pressure_delta > ONE_ATMOSPHERE)
			icon_state = "circ[flipped+1]-run"
		else
			icon_state = "circ[flipped+1]-slow"
		return ..()

	icon_state = "circ[flipped+1]-off"
	return ..()

/obj/machinery/atmospherics/components/binary/circulator/update_overlays()
	. = ..()
	if(active)
		.+= emissive_appearance(icon, "[icon_state]-emissive", src)

/obj/machinery/atmospherics/components/binary/circulator/wrench_act_secondary(mob/living/user, obj/item/tool)
	if(!panel_open)
		balloon_alert(user, "open the panel!")
		return
	var/turf/open/turf = get_turf(get_step(src, NORTH))
	if(!isopenturf(turf))
		return
	balloon_alert(user, "You drain the lubricant tank.")
	turf.add_liquid_from_reagents(reagents)
	reagents.remove_all(reagent_buffer)

/obj/machinery/atmospherics/components/binary/circulator/wrench_act(mob/living/user, obj/item/I)
	if(!panel_open)
		balloon_alert(user, "open the panel!")
		return
	set_anchored(!anchored)
	I.play_tool_sound(src)
	if(generator)
		disconnectFromGenerator()
	balloon_alert(user, "[anchored ? "secure" : "unsecure"]")

	var/obj/machinery/atmospherics/node1 = nodes[1]
	var/obj/machinery/atmospherics/node2 = nodes[2]

	if(node1)
		node1.disconnect(src)
		nodes[1] = null
		if(parents[1])
			nullify_pipenet(parents[1])

	if(node2)
		node2.disconnect(src)
		nodes[2] = null
		if(parents[2])
			nullify_pipenet(parents[2])

	if(anchored)
		set_init_directions()
		atmos_init()
		node1 = nodes[1]
		if(node1)
			node1.atmos_init()
			node1.add_member(src)
		node2 = nodes[2]
		if(node2)
			node2.atmos_init()
			node2.add_member(src)
		SSair.add_to_rebuild_queue(src)

	return TRUE

/obj/machinery/atmospherics/components/binary/circulator/set_init_directions()
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = NORTH|SOUTH

/obj/machinery/atmospherics/components/binary/circulator/get_node_connects()
	if(flipped)
		return list(SOUTH, NORTH)
	return list(NORTH, SOUTH)

/obj/machinery/atmospherics/components/binary/circulator/can_be_node(obj/machinery/atmospherics/target)
	if(anchored)
		return ..(target)
	return FALSE

/obj/machinery/atmospherics/components/binary/circulator/multitool_act(mob/living/user, obj/item/I)
	if(generator)
		disconnectFromGenerator()
	mode = !mode
	if(mode)
		flipped = TRUE
	else
		flipped = FALSE
	balloon_alert(user, "set to [mode ? "cold" : "hot"]")
	return TRUE

/obj/machinery/atmospherics/components/binary/circulator/screwdriver_act(mob/user, obj/item/I)
	if(!anchored)
		balloon_alert(user, "anchor it down!")
		return
	toggle_panel_open()
	I.play_tool_sound(src)
	balloon_alert(user, "panel [panel_open ? "open" : "closed"]")
	if(panel_open)
		reagents.flags |= (TRANSPARENT | OPENCONTAINER)
	else
		reagents.flags &= ~(TRANSPARENT | OPENCONTAINER)
	return TRUE

/obj/machinery/atmospherics/components/binary/circulator/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(I))
		return TRUE
	return ..()

/obj/machinery/atmospherics/components/binary/circulator/on_deconstruction()
	if(generator)
		disconnectFromGenerator()

/obj/machinery/atmospherics/components/binary/circulator/proc/disconnectFromGenerator()
	if(mode)
		generator.cold_circ = null
	else
		generator.hot_circ = null
	generator.update_appearance()
	generator = null

/obj/machinery/atmospherics/components/binary/circulator/set_piping_layer(new_layer)
	..()
	pixel_x = 0
	pixel_y = 0
