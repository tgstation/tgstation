
/*
4-way manifold
*/
/obj/machinery/atmospherics/pipe/manifold4w
	icon = 'icons/obj/atmospherics/pipe_manifold.dmi'
	icon_state = "manifold4w"

	name = "4-way pipe manifold"
	desc = "A manifold composed of regular pipes"

	volume = 140

	initialize_directions = NORTH|SOUTH|EAST|WEST

	var/obj/machinery/atmospherics/node1 // North
	var/obj/machinery/atmospherics/node2 // South
	var/obj/machinery/atmospherics/node3 // East
	var/obj/machinery/atmospherics/node4 // West

/obj/machinery/atmospherics/pipe/manifold4w/New()
	color = pipe_color
	..()

/obj/machinery/atmospherics/pipe/manifold4w/initialize()
	for(var/D in cardinal)
		for(var/obj/machinery/atmospherics/target in get_step(src, D))
			if(target.initialize_directions & get_dir(target,src))
				if(D == NORTH)
					node1 = target
				else if(D == SOUTH)
					node2 = target
				else if(D == EAST)
					node3 = target
				else if(D == WEST)
					node4 = target
				break

	..()

/obj/machinery/atmospherics/pipe/manifold4w/pipeline_expansion()
	return list(node1, node2, node3, node4)

/obj/machinery/atmospherics/pipe/manifold4w/Destroy()
	if(node1)
		var/obj/machinery/atmospherics/A = node1
		node1.disconnect(src)
		node1 = null
		A.build_network()
	if(node2)
		var/obj/machinery/atmospherics/A = node2
		node2.disconnect(src)
		node2 = null
		A.build_network()
	if(node3)
		var/obj/machinery/atmospherics/A = node3
		node3.disconnect(src)
		node3 = null
		A.build_network()
	if(node4)
		var/obj/machinery/atmospherics/A = node4
		node4.disconnect(src)
		node4 = null
		A.build_network()
	releaseAirToTurf()
	..()

/obj/machinery/atmospherics/pipe/manifold4w/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node1 = null
	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node2 = null
	if(reference == node3)
		if(istype(node3, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node3 = null
	if(reference == node4)
		if(istype(node4, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node4 = null
	update_icon()
	..()

/obj/machinery/atmospherics/pipe/manifold4w/update_icon()

	icon_state = "manifold4w_center"

	underlays.Cut()

	//Add non-broken pieces
	if(node1)
		underlays += getpipeimage('icons/obj/atmospherics/pipe_manifold.dmi', "manifold_full", NORTH)
	else
		underlays += getpipeimage('icons/obj/atmospherics/pipe_manifold.dmi', "manifold_broken", NORTH)

	if(node2)
		underlays += getpipeimage('icons/obj/atmospherics/pipe_manifold.dmi', "manifold_full", SOUTH)
	else
		underlays += getpipeimage('icons/obj/atmospherics/pipe_manifold.dmi', "manifold_broken", SOUTH)

	if(node3)
		underlays += getpipeimage('icons/obj/atmospherics/pipe_manifold.dmi', "manifold_full", EAST)
	else
		underlays += getpipeimage('icons/obj/atmospherics/pipe_manifold.dmi', "manifold_broken", EAST)

	if(node4)
		underlays += getpipeimage('icons/obj/atmospherics/pipe_manifold.dmi', "manifold_full", WEST)
	else
		underlays += getpipeimage('icons/obj/atmospherics/pipe_manifold.dmi', "manifold_broken", WEST)

	if(!pipe_color)
		pipe_color = (node1 && node1.pipe_color) || (node2 && node2.pipe_color) || (node3 && node3.pipe_color) || (node4 && node4.pipe_color) || pipe_color
		color = pipe_color

//Colored pipes, use these for mapping
/obj/machinery/atmospherics/pipe/manifold4w/general
	name="pipe"

/obj/machinery/atmospherics/pipe/manifold4w/general/visible
	layer = ATMOSPHERIC_MACHINE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/general/hidden

/obj/machinery/atmospherics/pipe/manifold4w/scrubbers
	name="scrubbers pipe"
	pipe_color=rgb(255,0,0)
	color=rgb(255,0,0)

/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/visible
	layer = ATMOSPHERIC_MACHINE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/hidden

/obj/machinery/atmospherics/pipe/manifold4w/supply
	name="air supply pipe"
	pipe_color=rgb(0,0,255)
	color=rgb(0,0,255)

/obj/machinery/atmospherics/pipe/manifold4w/supply/visible
	layer = ATMOSPHERIC_MACHINE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/supply/hidden

/obj/machinery/atmospherics/pipe/manifold4w/supplymain
	name="main air supply pipe"
	pipe_color=rgb(130,43,272)
	color=rgb(130,43,272)

/obj/machinery/atmospherics/pipe/manifold4w/supplymain/visible
	layer = ATMOSPHERIC_MACHINE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/supplymain/hidden

/obj/machinery/atmospherics/pipe/manifold4w/yellow
	pipe_color=rgb(255,198,0)
	color=rgb(255,198,0)

/obj/machinery/atmospherics/pipe/manifold4w/yellow/visible
	layer = ATMOSPHERIC_MACHINE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/yellow/hidden

/obj/machinery/atmospherics/pipe/manifold4w/cyan
	pipe_color=rgb(0,256,249)
	color=rgb(0,256,249)

/obj/machinery/atmospherics/pipe/manifold4w/cyan/visible
	layer = ATMOSPHERIC_MACHINE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/cyan/hidden

/obj/machinery/atmospherics/pipe/manifold4w/green
	pipe_color=rgb(30,256,0)
	color=rgb(30,256,0)

/obj/machinery/atmospherics/pipe/manifold4w/green/visible
	layer = ATMOSPHERIC_MACHINE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/green/hidden
