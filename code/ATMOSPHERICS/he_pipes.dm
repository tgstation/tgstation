
/obj/machinery/atmospherics/pipe/simple/heat_exchanging
	icon = 'icons/obj/pipes/heat.dmi'
	icon_state = "intact"
	level = 2
	var/initialize_directions_he

	minimum_temperature_difference = 20
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT


/obj/machinery/atmospherics/pipe/simple/heat_exchanging/getNodeType(var/node_id)
	return PIPE_TYPE_HE

	// BubbleWrap
/obj/machinery/atmospherics/pipe/simple/heat_exchanging/New()
	..()
	initialize_directions_he = initialize_directions	// The auto-detection from /pipe is good enough for a simple HE pipe
	// BubbleWrap END

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = 0
	initialize_directions_he = pipe.get_pipe_dir()
	//var/turf/T = loc
	//level = T.intact ? 2 : 1
	if(!initialize(1))
		usr << "Unable to build pipe here;  It must be connected to a machine, or another pipe that has a connection."
		return 0
	build_network()
	if (node1)
		node1.initialize()
		node1.build_network()
	if (node2)
		node2.initialize()
		node2.build_network()
	return 1

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/initialize(var/suppress_icon_check=0)
	normalize_dir()

	findAllConnections(initialize_directions_he)

	if(!suppress_icon_check)
		update_icon()
	return node1 || node2

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/process()
	if(!parent)
		..()
	else
		var/environment_temperature = 0
		if(istype(loc, /turf/simulated/) && !iscatwalk(loc))
			if(loc:blocks_air)
				environment_temperature = loc:temperature
			else
				var/datum/gas_mixture/environment = loc.return_air()
				environment_temperature = environment.temperature
		else
			environment_temperature = loc:temperature
		var/datum/gas_mixture/pipe_air = return_air()
		if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
			parent.temperature_interact(loc, volume, thermal_conductivity)

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/hidden
	level=1
	icon_state="intact-f"

/////////////////////////////////
// JUNCTION
/////////////////////////////////
/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction
	icon = 'icons/obj/pipes/junction.dmi'
	icon_state = "intact"
	level = 2
	minimum_temperature_difference = 300
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

	// BubbleWrap
/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/New()
	.. ()
	switch ( dir )
		if ( SOUTH )
			initialize_directions = NORTH
			initialize_directions_he = SOUTH
		if ( NORTH )
			initialize_directions = SOUTH
			initialize_directions_he = NORTH
		if ( EAST )
			initialize_directions = WEST
			initialize_directions_he = EAST
		if ( WEST )
			initialize_directions = EAST
			initialize_directions_he = WEST
	// BubbleWrap END

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = pipe.get_pdir()
	initialize_directions_he = pipe.get_hdir()
	if (!initialize(1))
		usr << "There's nothing to connect this junction to! (with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)"
		return 0
	build_network()
	if (node1)
		node1.initialize()
		node1.build_network()
	if (node2)
		node2.initialize()
		node2.build_network()
	return 1

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/update_icon()
	if(node1&&node2)
		icon_state = "intact[invisibility ? "-f" : "" ]"
	else
		var/have_node1 = node1?1:0
		var/have_node2 = node2?1:0
		icon_state = "exposed[have_node1][have_node2]"

	if(!node1&&!node2)
		qdel(src)

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/initialize(var/suppress_icon_check=0)
	node1 = findConnecting(initialize_directions)
	node2 = findConnectingHE(initialize_directions_he)

	if(!suppress_icon_check)
		update_icon()

	return node1 || node2

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/hidden
	level=1
	icon_state="intact-f"