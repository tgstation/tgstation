
/obj/machinery/atmospherics/unary/tank
	icon = 'icons/obj/atmospherics/pipe_tank.dmi'
	icon_state = "co2"
	name = "Pressure Tank"
	desc = "A large vessel containing pressurized gas."
	starting_volume = 2000 //in liters, 1 meters by 1 meters by 2 meters
	dir = SOUTH
	initialize_directions = SOUTH
	density = 1
	default_colour = "#b77900"
/obj/machinery/atmospherics/unary/tank/process()
	if(!network)
		. = ..()
	atmos_machines.Remove(src)
	/*			if(!node1)
		parent.mingle_with_turf(loc, 200)
		if(!nodealert)
//			to_chat(world, "Missing node from [src] at [src.x],[src.y],[src.z]")
			nodealert = 1
	else if (nodealert)
		nodealert = 0
	*/

/obj/machinery/atmospherics/unary/tank/carbon_dioxide
	name = "Pressure Tank (Carbon Dioxide)"
/obj/machinery/atmospherics/unary/tank/carbon_dioxide/New()
	..()

	air_contents.carbon_dioxide = (25*ONE_ATMOSPHERE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)


/obj/machinery/atmospherics/unary/tank/toxins
	icon_state = "plasma"
	name = "Pressure Tank (Plasma)"

/obj/machinery/atmospherics/unary/tank/toxins/New()
	..()

	air_contents.toxins = (25*ONE_ATMOSPHERE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)


/obj/machinery/atmospherics/unary/tank/oxygen_agent_b
	icon_state = "plasma"
	name = "Pressure Tank (Oxygen + Plasma)"

/obj/machinery/atmospherics/unary/tank/oxygen_agent_b/New()
	..()

	var/datum/gas/oxygen_agent_b/trace_gas = new
	trace_gas.moles = (25*ONE_ATMOSPHERE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	air_contents.trace_gases += trace_gas


/obj/machinery/atmospherics/unary/tank/oxygen
	icon_state = "o2"
	name = "Pressure Tank (Oxygen)"
	default_colour = "#00b8b8"

/obj/machinery/atmospherics/unary/tank/oxygen/New()
	..()

	air_contents.oxygen = (25*ONE_ATMOSPHERE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/nitrogen
	icon_state = "n2"
	name = "Pressure Tank (Nitrogen)"
	default_colour = "#00b8b8"

/obj/machinery/atmospherics/unary/tank/nitrogen/New()
	..()

	air_contents.nitrogen = (25*ONE_ATMOSPHERE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/air
	icon_state = "air"
	name = "Pressure Tank (Air)"
	default_colour = "#0000b7"

/obj/machinery/atmospherics/unary/tank/air/New()
	..()

	air_contents.oxygen = (25*ONE_ATMOSPHERE*O2STANDARD)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.nitrogen = (25*ONE_ATMOSPHERE*N2STANDARD)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/update_icon()
	..()

/obj/machinery/atmospherics/unary/tank/disconnect(obj/machinery/atmospherics/reference)
	..()
	update_icon()


/obj/machinery/atmospherics/unary/tank/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/device/rcd/rpd) || istype(W, /obj/item/device/pipe_painter))
		return // Coloring pipes.
	if (istype(W, /obj/item/device/analyzer) && get_dist(user, src) <= 1)
		user.visible_message("<span class='attack'>[user] has used [W] on \icon[icon] [src]</span>", "<span class='attack'>You use \the [W] on \icon[icon] [src]</span>")
		var/obj/item/device/analyzer/analyzer = W
		user.show_message(analyzer.output_gas_scan(air_contents, src, 0), 1)
