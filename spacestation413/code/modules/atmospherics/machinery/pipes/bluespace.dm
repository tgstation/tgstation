GLOBAL_LIST_EMPTY(bluespace_pipe_networks)
/obj/machinery/atmospherics/pipe/bluespace
	name = "bluespace pipe"
	desc = "Transmits gas across large distances of space. Developed using bluespace technology."
	icon = 'yogstation/icons/obj/atmospherics/pipes/bluespace.dmi'
	icon_state = "map"
	pipe_state = "bluespace"
	dir = SOUTH
	initialize_directions = SOUTH
	device_type = UNARY
	can_buckle = FALSE
	construction_type = /obj/item/pipe/bluespace
	var/bluespace_network_name

/obj/machinery/atmospherics/pipe/bluespace/New()
	icon_state = "pipe"
	if(bluespace_network_name) // in case someone maps one in for some reason
		if(!GLOB.bluespace_pipe_networks[bluespace_network_name])
			GLOB.bluespace_pipe_networks[bluespace_network_name] = list()
		GLOB.bluespace_pipe_networks[bluespace_network_name] |= src
	..()

/obj/machinery/atmospherics/pipe/bluespace/on_construction()
	. = ..()
	if(bluespace_network_name)
		if(!GLOB.bluespace_pipe_networks[bluespace_network_name])
			GLOB.bluespace_pipe_networks[bluespace_network_name] = list()
		GLOB.bluespace_pipe_networks[bluespace_network_name] |= src

/obj/machinery/atmospherics/pipe/bluespace/Destroy()
	if(GLOB.bluespace_pipe_networks[bluespace_network_name])
		GLOB.bluespace_pipe_networks[bluespace_network_name] -= src
		for(var/p in GLOB.bluespace_pipe_networks[bluespace_network_name])
			var/obj/machinery/atmospherics/pipe/bluespace/P = p
			QDEL_NULL(P.parent)
			P.build_network()
	return ..()

/obj/machinery/atmospherics/pipe/bluespace/examine(user)
	. = ..()
	to_chat(user, "<span class='notice'>This one is connected to the \"[html_encode(bluespace_network_name)]\" network</span>")

/obj/machinery/atmospherics/pipe/bluespace/SetInitDirections()
	initialize_directions = dir

/obj/machinery/atmospherics/pipe/bluespace/pipeline_expansion()
	return ..() + GLOB.bluespace_pipe_networks[bluespace_network_name] - src

/obj/machinery/atmospherics/pipe/bluespace/hide()
	update_icon()

/obj/machinery/atmospherics/pipe/bluespace/update_icon(showpipe)
	underlays.Cut()

	var/turf/T = loc
	if(level == 2 || !T.intact)
		showpipe = TRUE
		plane = GAME_PLANE
	else
		showpipe = FALSE
		plane = FLOOR_PLANE

	if(!showpipe)
		return //no need to update the pipes if they aren't showing

	var/connected = 0 //Direction bitset

	for(var/i in 1 to device_type) //adds intact pieces
		if(nodes[i])
			var/obj/machinery/atmospherics/node = nodes[i]
			var/image/img = get_pipe_underlay("pipe_intact", get_dir(src, node), node.pipe_color)
			underlays += img
			connected |= img.dir

	for(var/direction in GLOB.cardinals)
		if((initialize_directions & direction) && !(connected & direction))
			underlays += get_pipe_underlay("pipe_exposed", direction)

/obj/machinery/atmospherics/pipe/bluespace/paint()
	return FALSE

/obj/machinery/atmospherics/pipe/bluespace/proc/get_pipe_underlay(state, dir, color = null)
	if(color)
		. = getpipeimage('icons/obj/atmospherics/components/binary_devices.dmi', state, dir, color)
	else
		. = getpipeimage('icons/obj/atmospherics/components/binary_devices.dmi', state, dir)