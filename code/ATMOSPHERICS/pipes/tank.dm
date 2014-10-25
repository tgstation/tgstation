
/*
Atmospheric Tanks
*/
/obj/machinery/atmospherics/pipe/tank
	icon = 'icons/obj/atmospherics/pipe_tank.dmi'
	icon_state = "generic"

	name = "pressure tank"
	desc = "A large vessel containing pressurized gas."

	volume = 10000 //in liters, 1 meters by 1 meters by 2 meters

	dir = SOUTH
	initialize_directions = SOUTH
	density = 1
	can_unwrench = 0
	var/obj/machinery/atmospherics/node
	var/showpipe = 0

/obj/machinery/atmospherics/pipe/tank/New()
	initialize_directions = dir
	..()

/obj/machinery/atmospherics/pipe/tank/hide(var/intact)
	showpipe = !intact
	update_icon()

	..(intact)

/obj/machinery/atmospherics/pipe/tank/Destroy()
	if(node)
		node.disconnect(src)
	..()

/obj/machinery/atmospherics/pipe/tank/pipeline_expansion()
	return list(node)

/obj/machinery/atmospherics/pipe/tank/update_icon()
	underlays.Cut()
	if(showpipe)
		var/state
		var/col
		if(node)
			state = "pipe_intact"
			col = node.pipe_color
		else
			state = "pipe_exposed"

		underlays += getpipeimage('icons/obj/atmospherics/pipe_tank.dmi', state, initialize_directions, col)

/obj/machinery/atmospherics/pipe/tank/initialize()
	var/connect_direction = dir
	for(var/obj/machinery/atmospherics/target in get_step(src,connect_direction))
		if(target.initialize_directions & get_dir(target,src))
			node = target
			break

	if(level == 2)
		showpipe = 1

	update_icon()

/obj/machinery/atmospherics/pipe/tank/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node)
		if(istype(node, /obj/machinery/atmospherics/pipe))
			del(parent)
		node = null
	update_icon()


/*
CO2 Tank
*/
/obj/machinery/atmospherics/pipe/tank/carbon_dioxide
	name = "pressure tank (Carbon Dioxide)"

/obj/machinery/atmospherics/pipe/tank/carbon_dioxide/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.carbon_dioxide = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

	..()

/*
Plasma Tank
*/
/obj/machinery/atmospherics/pipe/tank/toxins
	icon_state = "orange"
	name = "pressure tank (Plasma)"

/obj/machinery/atmospherics/pipe/tank/toxins/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.toxins = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

	..()

/*
Plasma + Oxygen Tank
*/
/obj/machinery/atmospherics/pipe/tank/oxygen_agent_b
	icon_state = "orange_2"
	name = "pressure tank (Oxygen + Plasma)"

/obj/machinery/atmospherics/pipe/tank/oxygen_agent_b/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T0C

	var/datum/gas/oxygen_agent_b/trace_gas = new
	trace_gas.moles = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

	air_temporary.trace_gases += trace_gas

	..()

/*
Oxygen Tank
*/
/obj/machinery/atmospherics/pipe/tank/oxygen
	icon_state = "blue"
	name = "pressure tank (Oxygen)"

/obj/machinery/atmospherics/pipe/tank/oxygen/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.oxygen = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

	..()

/*
Nitrogen Tank
*/
/obj/machinery/atmospherics/pipe/tank/nitrogen
	icon_state = "red"
	name = "pressure tank (Nitrogen)"

/obj/machinery/atmospherics/pipe/tank/nitrogen/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.nitrogen = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

	..()

/*
Air Tank
*/
/obj/machinery/atmospherics/pipe/tank/air
	icon_state = "grey"
	name = "pressure tank (Air)"

/obj/machinery/atmospherics/pipe/tank/air/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.oxygen = (25*ONE_ATMOSPHERE*O2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)
	air_temporary.nitrogen = (25*ONE_ATMOSPHERE*N2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

	..()