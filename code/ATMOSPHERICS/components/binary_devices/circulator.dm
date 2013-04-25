//node1, air1, network1 correspond to input
//node2, air2, network2 correspond to output

#define CIRCULATOR_MIN_PRESSURE 10 //KPA to move the mechanism
#define CIRCULATOR_VOLUME 100 //Litres
#define CIRCULATOR_EFFICIENCY 0.65 //Out of 1.

#define TURBINE_EFFICIENCY 0.1 //Uses more power than is generated.
#define TURBINE_PRESSURE_DIFFERENCE 20 //Simulates a 20KPa difference
#define GENRATE 800

/obj/machinery/atmospherics/binary/circulator
	name = "circulator/heat exchanger"
	desc = "A gas circulator pump and heat exchanger."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "circ-off"
	anchored = 0

	//var/side = 1 // 1=left 2=right
	var/status = 0

	var/datum/gas_mixture/gas_contents
	var/last_pressure_delta = 0
	var/turbine_pumping = 0 //For when there is not enough pressure difference and we need to induce one or something.
	var/last_power_generation = 0

	density = 1

/obj/machinery/atmospherics/binary/circulator/New()
	..()
	desc = initial(desc) + "  Its outlet port is to the [dir2text(dir)]."
	gas_contents = new
	gas_contents.volume = CIRCULATOR_VOLUME


/obj/machinery/atmospherics/binary/circulator/proc/return_transfer_air()
	if(!anchored)
		return null

	var/output_starting_pressure = air2.return_pressure()
	var/input_starting_pressure = air1.return_pressure()
	var/internal_gas_pressure = gas_contents.return_pressure()

	var/intake_pressure_delta = input_starting_pressure - internal_gas_pressure
	var/output_pressure_delta = internal_gas_pressure - output_starting_pressure

	var/pressure_delta = max(intake_pressure_delta, output_pressure_delta, 0)

	last_power_generation = 0
	//If the turbine is running, we need to consider that.
	if(turbine_pumping)
		//Make it use powah
		if(pressure_delta < TURBINE_PRESSURE_DIFFERENCE)
			last_power_generation = (pressure_delta - TURBINE_PRESSURE_DIFFERENCE)*(1/TURBINE_EFFICIENCY)
			pressure_delta = TURBINE_PRESSURE_DIFFERENCE

		//If the force is already above what the turbine can do, shut it off and generate power instead!
		else
			turbine_pumping = 0

	//Calculate necessary moles to transfer using PV = nRT
	if(air1.temperature > 0)

		var/transfer_moles = pressure_delta*gas_contents.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

		last_pressure_delta = pressure_delta

		//Actually transfer the gas
		//Internal to output.
		air2.merge(gas_contents.remove(transfer_moles))

		//Intake to internal.
		gas_contents.merge(air1.remove(transfer_moles))

		//Update the gas networks.
		if(network1)
			network1.update = 1

		if(network2)
			network2.update = 1

	else
		last_pressure_delta = 0

	//Needs at least 10 KPa difference to move the mechanism and make power
	if(pressure_delta < CIRCULATOR_MIN_PRESSURE)
		last_pressure_delta = 0

	last_power_generation += pressure_delta*CIRCULATOR_EFFICIENCY

	return gas_contents



//Used by the TEG to know how much power to use/produce.
/obj/machinery/atmospherics/binary/circulator/proc/ReturnPowerGeneration()
	return GENRATE*last_power_generation


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