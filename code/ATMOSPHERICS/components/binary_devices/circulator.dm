//node1, air1, network1 correspond to input
//node2, air2, network2 correspond to output

/obj/machinery/atmospherics/binary/circulator
	name = "circulator/heat exchanger"
	desc = "A gas circulator pump and heat exchanger."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "circ-off"
	anchored = 0

	//var/side = 1 // 1=left 2=right
	var/status = 0

	var/last_pressure_delta = 0

	density = 1

/obj/machinery/atmospherics/binary/circulator/New()
	..()
	desc = initial(desc) + " Its outlet port is to the [dir2text(dir)]."

/obj/machinery/atmospherics/binary/circulator/proc/return_transfer_air()
	if(!anchored)
		return null

	var/output_starting_pressure = air2.return_pressure()
	var/input_starting_pressure = air1.return_pressure()

	if(output_starting_pressure >= input_starting_pressure-10)
		//Need at least 10 KPa difference to overcome friction in the mechanism
		last_pressure_delta = 0
		return null

	//Calculate necessary moles to transfer using PV = nRT
	if(air1.temperature>0)
		var/pressure_delta = (input_starting_pressure - output_starting_pressure)/2

		var/transfer_moles = pressure_delta*air2.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

		last_pressure_delta = pressure_delta

		//world << "pressure_delta = [pressure_delta]; transfer_moles = [transfer_moles];"

		//Actually transfer the gas
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)

		if(network1)
			network1.update = 1

		if(network2)
			network2.update = 1

		return removed

	else
		last_pressure_delta = 0

/obj/machinery/atmospherics/binary/circulator/process()
	..()
	update_icon()

/obj/machinery/atmospherics/binary/circulator/update_icon()
	if(stat & (BROKEN|NOPOWER) || !anchored)
		icon_state = "circ-p"
	else if(last_pressure_delta > 0)
		if(last_pressure_delta > ONE_ATMOSPHERE)
			icon_state = "circ-run"
		else
			icon_state = "circ-slow"
	else
		icon_state = "circ-off"

	return 1

/obj/machinery/atmospherics/binary/circulator/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		anchored = !anchored
		user << "\blue You [anchored ? "secure" : "unsecure"] the bolts holding [src] to the floor."

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

	else
		..()

/obj/machinery/atmospherics/binary/circulator/verb/rotate()
	set category = "Object"
	set name = "Rotate Circulator"
	set src in view(1)

	if (usr.stat || usr.restrained() || anchored)
		return

	src.dir = turn(src.dir, 90)
	desc = initial(desc) + " Its outlet port is to the [dir2text(dir)]."
