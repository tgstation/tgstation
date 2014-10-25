//node1, air1, network1 correspond to input
//node2, air2, network2 correspond to output

/obj/machinery/atmospherics/binary/circulator
	name = "circulator/heat exchanger"
	desc = "A gas circulator pump and heat exchanger."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "circ-off"
	anchored = 0

	var/recent_moles_transferred = 0
	var/last_heat_capacity = 0
	var/last_temperature = 0
	var/last_pressure_delta = 0
	var/last_worldtime_transfer = 0

	density = 1

	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/atmospherics/binary/circulator/New()
	..()
	desc = initial(desc) + "  Its outlet port is to the [dir2text(dir)]."

/obj/machinery/atmospherics/binary/circulator/proc/return_transfer_air()
	var/datum/gas_mixture/removed
	if(anchored && !(stat&BROKEN) )
		var/input_starting_pressure = air1.return_pressure()
		var/output_starting_pressure = air2.return_pressure()
		last_pressure_delta = max(input_starting_pressure - output_starting_pressure + 10, 0)

		//only circulate air if there is a pressure difference (plus 10 kPa to represent friction in the machine)
		if(air1.temperature > 0 && last_pressure_delta > 0)

			//Calculate necessary moles to transfer using PV = nRT
			recent_moles_transferred = last_pressure_delta*air2.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			removed = air1.remove(recent_moles_transferred)
			if(removed)
				last_heat_capacity = removed.heat_capacity()
				last_temperature = removed.temperature

				//Update the gas networks.
				if(network1)
					network1.update = 1

				last_worldtime_transfer = world.time
		else
			recent_moles_transferred = 0

		update_icon()
		return removed

/obj/machinery/atmospherics/binary/circulator/process()
	..()

	if(last_worldtime_transfer < world.time - 50)
		recent_moles_transferred = 0
		update_icon()

/obj/machinery/atmospherics/binary/circulator/update_icon()
	if(stat & (BROKEN|NOPOWER) || !anchored)
		icon_state = "circ-p"
	else if(last_pressure_delta > 0 && recent_moles_transferred > 0)
		if(last_pressure_delta > 5*ONE_ATMOSPHERE)
			icon_state = "circ-run"
		else
			icon_state = "circ-slow"
	else
		icon_state = "circ-off"

	return 1

/obj/machinery/atmospherics/binary/circulator/wrenchAnchor(mob/user)
	..()
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
	else
		if(node1)
			node1.disconnect(src)
			del(network1)
		if(node2)
			node2.disconnect(src)
			del(network2)

		node1 = null
		node2 = null

/obj/machinery/atmospherics/binary/circulator/verb/rotate_clockwise()
	set category = "Object"
	set name = "Rotate Circulator (Clockwise)"
	set src in view(1)

	if (usr.stat || usr.restrained() || anchored)
		return

	src.dir = turn(src.dir, 90)
	desc = initial(desc) + " Its outlet port is to the [dir2text(dir)]."


/obj/machinery/atmospherics/binary/circulator/verb/rotate_anticlockwise()
	set category = "Object"
	set name = "Rotate Circulator (Counterclockwise)"
	set src in view(1)

	if (usr.stat || usr.restrained() || anchored)
		return

	src.dir = turn(src.dir, -90)
	desc = initial(desc) + " Its outlet port is to the [dir2text(dir)]."