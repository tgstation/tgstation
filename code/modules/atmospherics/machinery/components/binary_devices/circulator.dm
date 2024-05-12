//node2, air2, network2 correspond to input
//node1, air1, network1 correspond to output

/obj/machinery/atmospherics/components/binary/circulator
	name = "circulator/heat exchanger"
	desc = "A gas circulator pump and heat exchanger."
	icon_state = "circ_base"
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

/obj/machinery/atmospherics/components/binary/circulator/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)

//default cold circ for mappers
/obj/machinery/atmospherics/components/binary/circulator/cold
	mode = CIRCULATOR_COLD

/obj/machinery/atmospherics/components/binary/circulator/Destroy()
	if(generator)
		disconnectFromGenerator()
	return ..()

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
	var/transfer_moles = (pressure_delta*air1.volume)/(air2.temperature * R_IDEAL_GAS_EQUATION)
	last_pressure_delta = pressure_delta
	//Actually transfer the gas
	var/datum/gas_mixture/removed = air2.remove(transfer_moles)
	update_parents()
	return removed

/obj/machinery/atmospherics/components/binary/circulator/process_atmos()
	update_appearance()

/obj/machinery/atmospherics/components/binary/circulator/update_overlays()
	. = ..()
	cut_overlays()
	if(anchored)
		add_overlay("circ_anchor")
	add_overlay("panel_[panel_open]")

	if(!is_operational)
		add_overlay("fan_[mode]")
		add_overlay("flow")
		add_overlay("display")
		return

	add_overlay("flow_on")
	add_overlay("display_[mode]")
	if(last_pressure_delta > 0)
		add_overlay("fan_[mode]_[last_pressure_delta > ONE_ATMOSPHERE]")
	else
		add_overlay("fan_[mode]")

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
			initialize_directions = EAST|WEST
		if(EAST, WEST)
			initialize_directions = NORTH|SOUTH

/obj/machinery/atmospherics/components/binary/circulator/get_node_connects()
	if(flipped)
		return list(turn(dir, 270), turn(dir, 90))
	return list(turn(dir, 90), turn(dir, 270))

/obj/machinery/atmospherics/components/binary/circulator/can_be_node(obj/machinery/atmospherics/target)
	if(anchored)
		return ..(target)
	return FALSE

/obj/machinery/atmospherics/components/binary/circulator/multitool_act(mob/living/user, obj/item/I)
	if(generator)
		disconnectFromGenerator()
	mode = !mode
	balloon_alert(user, "set to [mode ? "cold" : "hot"]")
	return TRUE

/obj/machinery/atmospherics/components/binary/circulator/screwdriver_act(mob/user, obj/item/I)
	if(!anchored)
		balloon_alert(user, "anchor it down!")
		return
	toggle_panel_open()
	I.play_tool_sound(src)
	balloon_alert(user, "panel [panel_open ? "open" : "closed"]")
	return TRUE

/obj/machinery/atmospherics/components/binary/circulator/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(I))
		return TRUE
	return ..()

/obj/machinery/atmospherics/components/binary/circulator/on_deconstruction(disassembled)
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
