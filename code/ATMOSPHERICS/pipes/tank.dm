/obj/machinery/atmospherics/unary/tank
	icon = 'icons/obj/atmospherics/pressure_tank.dmi'
	icon_state = "generic"
	name = "pressure tank"
	desc = "A large vessel containing pressurized gas."
	var/volume = 10000 //in liters, 1 meters by 1 meters by 2 meters
	density = 1

/obj/machinery/atmospherics/unary/tank/update_icon()
	underlays.Cut()
	if(showpipe)
		var/state
		var/col
		if(node)
			state = "pipe_intact"
			col = node.pipe_color
		else
			state = "pipe_exposed"
		underlays += getpipeimage('icons/obj/atmospherics/pressure_tank.dmi', state, initialize_directions, col)

/obj/machinery/atmospherics/unary/tank/carbon_dioxide
	name = "pressure tank (Carbon Dioxide)"

/obj/machinery/atmospherics/unary/tank/carbon_dioxide/New()
	..()
	air_contents.volume = volume
	air_contents.temperature = T20C
	air_contents.carbon_dioxide = (25*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/toxins
	icon_state = "orange"
	name = "pressure tank (Plasma)"

/obj/machinery/atmospherics/unary/tank/toxins/New()
	..()
	air_contents.volume = volume
	air_contents.temperature = T20C
	air_contents.toxins = (25*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/oxygen_agent_b
	icon_state = "orange_2"
	name = "pressure tank (Oxygen + Plasma)"

/obj/machinery/atmospherics/unary/tank/oxygen_agent_b/New()
	..()
	air_contents.volume = volume
	air_contents.temperature = T0C
	var/datum/gas/oxygen_agent_b/trace_gas = new
	trace_gas.moles = (25*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.trace_gases += trace_gas

/obj/machinery/atmospherics/unary/tank/oxygen
	icon_state = "blue"
	name = "pressure tank (Oxygen)"

/obj/machinery/atmospherics/unary/tank/oxygen/New()
	..()
	air_contents.volume = volume
	air_contents.temperature = T20C
	air_contents.oxygen = (25*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/nitrogen
	icon_state = "red"
	name = "pressure tank (Nitrogen)"

/obj/machinery/atmospherics/unary/tank/nitrogen/New()
	..()
	air_contents.volume = volume
	air_contents.temperature = T20C
	air_contents.nitrogen = (25*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/air
	icon_state = "grey"
	name = "pressure tank (Air)"

/obj/machinery/atmospherics/unary/tank/air/New()
	..()
	air_contents.volume = volume
	air_contents.temperature = T20C
	air_contents.oxygen = (25*ONE_ATMOSPHERE*O2STANDARD)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.nitrogen = (25*ONE_ATMOSPHERE*N2STANDARD)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)