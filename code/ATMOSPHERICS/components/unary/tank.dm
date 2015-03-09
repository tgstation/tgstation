
/obj/machinery/atmospherics/unary/tank
	icon = 'icons/obj/atmospherics/pipe_tank.dmi'
	icon_state = "intact"
	name = "Pressure Tank"
	desc = "A large vessel containing pressurized gas."
	starting_volume = 2000 //in liters, 1 meters by 1 meters by 2 meters
	dir = SOUTH
	initialize_directions = SOUTH
	density = 1

/obj/machinery/atmospherics/unary/tank/process()
	if(!network)
		..()
	else
		. = PROCESS_KILL
	/*			if(!node1)
		parent.mingle_with_turf(loc, 200)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
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
	icon = 'icons/obj/atmospherics/orange_pipe_tank.dmi'
	name = "Pressure Tank (Plasma)"

/obj/machinery/atmospherics/unary/tank/toxins/New()
	..()

	air_contents.toxins = (25*ONE_ATMOSPHERE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)


/obj/machinery/atmospherics/unary/tank/oxygen_agent_b
	icon = 'icons/obj/atmospherics/red_orange_pipe_tank.dmi'
	name = "Pressure Tank (Oxygen + Plasma)"

/obj/machinery/atmospherics/unary/tank/oxygen_agent_b/New()
	..()

	var/datum/gas/oxygen_agent_b/trace_gas = new
	trace_gas.moles = (25*ONE_ATMOSPHERE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	air_contents.trace_gases += trace_gas


/obj/machinery/atmospherics/unary/tank/oxygen
	icon = 'icons/obj/atmospherics/blue_pipe_tank.dmi'
	name = "Pressure Tank (Oxygen)"

/obj/machinery/atmospherics/unary/tank/oxygen/New()
	..()

	air_contents.oxygen = (25*ONE_ATMOSPHERE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/nitrogen
	icon = 'icons/obj/atmospherics/red_pipe_tank.dmi'
	name = "Pressure Tank (Nitrogen)"

/obj/machinery/atmospherics/unary/tank/nitrogen/New()
	..()

	air_contents.nitrogen = (25*ONE_ATMOSPHERE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/air
	icon = 'icons/obj/atmospherics/red_pipe_tank.dmi'
	name = "Pressure Tank (Air)"

/obj/machinery/atmospherics/unary/tank/air/New()
	..()

	air_contents.oxygen = (25*ONE_ATMOSPHERE*O2STANDARD)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.nitrogen = (25*ONE_ATMOSPHERE*N2STANDARD)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/update_icon()
	if(node)
		icon_state = "intact"
		dir = get_dir(src, node)
	else
		icon_state = "exposed"

/obj/machinery/atmospherics/unary/tank/disconnect(obj/machinery/atmospherics/reference)
	..()
	update_icon()


/obj/machinery/atmospherics/unary/tank/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/weapon/pipe_dispenser) || istype(W, /obj/item/device/pipe_painter))
		return // Coloring pipes.
	if (istype(W, /obj/item/device/analyzer) && get_dist(user, src) <= 1)
		user.visible_message("<span class='attack'>[user] has used [W] on \icon[icon] [src]</span>", "<span class='attack'>You use \the [W] on \icon[icon] [src]</span>")
		var/obj/item/device/analyzer/analyzer = W
		user.show_message(analyzer.output_gas_scan(air_contents, src, 0), 1)
