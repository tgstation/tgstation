//node1, air1, network1 correspond to input
//node2, air2, network2 correspond to output

/obj/machinery/atmospherics/binary/circulator
	name = "circulator"
	desc = "A gas circulator turbine and heat exchanger."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "circ-off"
	anchored = 0

	use_power = 0

	var/obj/machinery/power/generator/linked_generator

	var/kinetic_efficiency				= 0.04 //combined kinetic and kinetic-to-electric efficiency
	var/volume_ratio					= 0.2

	var/recent_moles_transferred		= 0
	var/last_heat_capacity				= 0
	var/last_temperature				= 0
	var/last_pressure_delta				= 0
	var/last_worldtime_transfer			= 0

	var/last_stored_energy_transferred	= 0
	var/volume_capacity_used			= 0
	var/stored_energy					= 0

	density = 1

	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/atmospherics/binary/circulator/New()
	. = ..()

/obj/machinery/atmospherics/binary/circulator/Destroy()
	. = ..()
	if(linked_generator)
		linked_generator.reconnect()

/obj/machinery/atmospherics/binary/circulator/examine(var/mob/user)
	. = ..()
	to_chat(user, "Its outlet port is to the [dir2text(dir)].")

/obj/machinery/atmospherics/binary/circulator/proc/return_transfer_air()
	if(!anchored || stat & BROKEN || !network1)
		return

	var/datum/gas_mixture/removed
	var/input_starting_pressure = air1.return_pressure()
	var/output_starting_pressure = air2.return_pressure()
	last_pressure_delta = max(input_starting_pressure - output_starting_pressure - 5, 0)

	//Only circulate air if there is a pressure difference (plus 5kPa kinetic, 10kPa static friction).
	if(air1.temperature > 0 && last_pressure_delta > 5)

		//Calculate necessary moles to transfer using PV = nRT.
		recent_moles_transferred = (last_pressure_delta * air2.volume / (air1.temperature * R_IDEAL_GAS_EQUATION))		//Uses the volume of the whole network, not just itself.
		volume_capacity_used = min((last_pressure_delta * air1.volume / 3) / (input_starting_pressure * air1.volume), 1)	//How much of the gas in the input air volume is consumed.

		//Calculate energy generated from kinetic turbine.
		stored_energy += 1 / ADIABATIC_EXPONENT * min(last_pressure_delta * air1.volume, input_starting_pressure * air1.volume) * (1 - volume_ratio ** ADIABATIC_EXPONENT) * kinetic_efficiency


		//Actually transfer the gas.
		removed = air1.remove(recent_moles_transferred)
		if(removed)
			last_heat_capacity = removed.heat_capacity()
			last_temperature = removed.temperature

			//Update the gas networks.
			network1.update = 1

			last_worldtime_transfer = world.time
	else
		recent_moles_transferred = 0

	update_icon()
	return removed

/obj/machinery/atmospherics/binary/circulator/proc/return_stored_energy()
	last_stored_energy_transferred = stored_energy
	stored_energy = 0
	return last_stored_energy_transferred

/obj/machinery/atmospherics/binary/circulator/process()
	. = ..()

	if(last_worldtime_transfer < world.time - 50)
		recent_moles_transferred = 0
		update_icon()

/obj/machinery/atmospherics/binary/circulator/update_icon()
	if(!linked_generator || linked_generator.stat & (NOPOWER | BROKEN))	//These get power from the TeG itself.
		icon_state = "circ-p"

	else if(last_pressure_delta > 0 && recent_moles_transferred > 0)
		if(last_pressure_delta >  5* ONE_ATMOSPHERE)
			icon_state = "circ-run"
		else
			icon_state = "circ-slow"
	else
		icon_state = "circ-off"

	return 1

/obj/machinery/atmospherics/binary/circulator/wrenchAnchor(mob/user)
	. = ..()
	if(anchored)
		if(dir & (NORTH|SOUTH))
			initialize_directions = NORTH|SOUTH
		else if(dir & (EAST|WEST))
			initialize_directions = EAST|WEST

		initialize()
		build_network()
		if (node1)
			node1.initialize()
			node1.build_network()
		if (node2)
			node2.initialize()
			node2.build_network()

		var/gendir = turn(dir, -90)
		for(var/obj/machinery/power/generator/pot_gen in get_step(src, gendir))
			pot_gen.reconnect()

	else
		if(node1)
			node1.disconnect(src)
			if(network1)
				returnToPool(network1)
		if(node2)
			node2.disconnect(src)
			if(network2)
				returnToPool(network2)

		node1 = null
		node2 = null

		linked_generator.reconnect()


/obj/machinery/atmospherics/binary/circulator/verb/rotate_clockwise()
	set category = "Object"
	set name = "Rotate Circulator (Clockwise)"
	set src in view(1)

	if(usr.isUnconscious() || usr.restrained() || anchored)
		return

	src.dir = turn(src.dir, 90)

/obj/machinery/atmospherics/binary/circulator/verb/rotate_anticlockwise()
	set category = "Object"
	set name = "Rotate Circulator (Counterclockwise)"
	set src in view(1)

	if(usr.isUnconscious() || usr.restrained() || anchored)
		return

	src.dir = turn(src.dir, -90)
