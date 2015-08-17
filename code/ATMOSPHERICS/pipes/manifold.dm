
/*
3-Way Manifold
*/

/obj/machinery/atmospherics/pipe/manifold
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold"

	name = "pipe manifold"
	desc = "A manifold composed of regular pipes"

	volume = 105

	dir = SOUTH
	initialize_directions = EAST|NORTH|WEST

	device_type = TRINARY
/*
/obj/machinery/atmospherics/pipe/manifold/New()
	color = pipe_color

	..()
*/
/obj/machinery/atmospherics/pipe/manifold/SetInitDirections()
	switch(dir)
		if(NORTH)
			initialize_directions = EAST|SOUTH|WEST
		if(SOUTH)
			initialize_directions = WEST|NORTH|EAST
		if(EAST)
			initialize_directions = SOUTH|WEST|NORTH
		if(WEST)
			initialize_directions = NORTH|EAST|SOUTH

/obj/machinery/atmospherics/pipe/manifold/atmosinit()
	var/node1_connect = turn(dir, 90)
	var/node2_connect = turn(dir, 270)
	var/node3_connect = turn(dir, 180)
	var/list/node_connects = list(node1_connect, node2_connect, node3_connect)
	..(node_connects)
/*
	for(var/D in cardinal)
		if(D == dir)
			continue
		for(var/obj/machinery/atmospherics/target in get_step(src, D))
			if(target.initialize_directions & get_dir(target,src))
				if(turn(dir, 90) == D)
					node1 = target
				if(turn(dir, 270) == D)
					node2 = target
				if(turn(dir, 180) == D)
					node3 = target
				break
	var/turf/T = src.loc			// hide if turf is not intact
	hide(T.intact)
	update_icon()
	..()

/obj/machinery/atmospherics/pipe/manifold/Destroy()
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
	releaseAirToTurf()
	..()

/obj/machinery/atmospherics/pipe/manifold/disconnect(obj/machinery/atmospherics/reference)
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
	update_icon()
	..()
*/
/obj/machinery/atmospherics/pipe/manifold/update_icon()
	var/invis = invisibility ? "-f" : ""

	icon_state = "manifold_center[invis]"

	overlays.Cut()

	//Add non-broken pieces
	for(DEVICE_TYPE_LOOP)
		if(NODE_I)
			overlays += getpipeimage('icons/obj/atmospherics/pipes/manifold.dmi', "manifold_full[invis]", get_dir(src, NODE_I))
/*
/obj/machinery/atmospherics/pipe/manifold/hide(i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()

/obj/machinery/atmospherics/pipe/manifold/pipeline_expansion()
	return list(node1, node2, node3)

/obj/machinery/atmospherics/pipe/manifold/update_node_icon()
	..()
	if(node1)
		node1.update_icon()
	if(node2)
		node2.update_icon()
	if(node3)
		node3.update_icon()
*/

//Colored pipes, use these for mapping
/obj/machinery/atmospherics/pipe/manifold/general
	name="pipe"

/obj/machinery/atmospherics/pipe/manifold/general/visible
	level = 2

/obj/machinery/atmospherics/pipe/manifold/general/hidden
	level = 1

/obj/machinery/atmospherics/pipe/manifold/scrubbers
	name="scrubbers pipe"
	pipe_color=rgb(255,0,0)
	color=rgb(255,0,0)

/obj/machinery/atmospherics/pipe/manifold/scrubbers/visible
	level = 2

/obj/machinery/atmospherics/pipe/manifold/scrubbers/hidden
	level = 1

/obj/machinery/atmospherics/pipe/manifold/supply
	name="air supply pipe"
	pipe_color=rgb(0,0,255)
	color=rgb(0,0,255)

/obj/machinery/atmospherics/pipe/manifold/supply/visible
	level = 2

/obj/machinery/atmospherics/pipe/manifold/supply/hidden
	level = 1

/obj/machinery/atmospherics/pipe/manifold/supplymain
	name="main air supply pipe"
	pipe_color=rgb(130,43,272)
	color=rgb(130,43,272)

/obj/machinery/atmospherics/pipe/manifold/supplymain/visible
	level = 2

/obj/machinery/atmospherics/pipe/manifold/supplymain/hidden
	level = 1

/obj/machinery/atmospherics/pipe/manifold/yellow
	pipe_color=rgb(255,198,0)
	color=rgb(255,198,0)

/obj/machinery/atmospherics/pipe/manifold/yellow/visible
	level = 2

/obj/machinery/atmospherics/pipe/manifold/yellow/hidden
	level = 1

/obj/machinery/atmospherics/pipe/manifold/cyan
	pipe_color=rgb(0,256,249)
	color=rgb(0,256,249)

/obj/machinery/atmospherics/pipe/manifold/cyan/visible
	level = 2

/obj/machinery/atmospherics/pipe/manifold/cyan/hidden
	level = 1

/obj/machinery/atmospherics/pipe/manifold/green
	pipe_color=rgb(30,256,0)
	color=rgb(30,256,0)

/obj/machinery/atmospherics/pipe/manifold/green/visible
	level = 2

/obj/machinery/atmospherics/pipe/manifold/green/hidden
	level = 1
