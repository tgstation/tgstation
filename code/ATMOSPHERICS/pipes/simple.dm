
/*
Simple Pipe
The regular pipe you see everywhere, including bent ones.
*/

/obj/machinery/atmospherics/pipe/simple
	icon = 'icons/obj/atmospherics/pipes/simple.dmi'
	icon_state = "intact"

	name = "pipe"
	desc = "A one meter section of regular pipe"

	volume = 70

	dir = SOUTH
	initialize_directions = SOUTH|NORTH

	device_type = BINARY
/*
/obj/machinery/atmospherics/pipe/simple/New()
	color = pipe_color

	..()
*/

/obj/machinery/atmospherics/pipe/simple/SetInitDirections()
	if(dir in diagonals)
		initialize_directions = dir
	switch(dir)
		if(NORTH)
			initialize_directions = SOUTH|NORTH
		if(SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST)
			initialize_directions = EAST|WEST
		if(WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/simple/atmosinit()
	normalize_dir()
	var/list/node_connects = list()

	if(dir in diagonals) //bent pipes
		for(var/D in cardinal)
			if(D & initialize_directions)
				node_connects |= D
	else //straight pipes
		var/node1_connect = dir
		var/node2_connect = turn(dir, 180)
		node_connects = list(node1_connect, node2_connect)

	..(node_connects)

/*
/obj/machinery/atmospherics/pipe/simple/Destroy()
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
	releaseAirToTurf()
	..()

/obj/machinery/atmospherics/pipe/simple/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node1 = null
	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node2 = null
	update_icon()
*/
/obj/machinery/atmospherics/pipe/simple/proc/normalize_dir()
	if(dir==2)
		dir = 1
	else if(dir==8)
		dir = 4

/obj/machinery/atmospherics/pipe/simple/update_icon()
	if(NODE1&&NODE2)
		icon_state = "intact[invisibility ? "-f" : "" ]"
	else
		var/have_node1 = NODE1?1:0
		var/have_node2 = NODE2?1:0
		icon_state = "exposed[have_node1][have_node2][invisibility ? "-f" : "" ]"
/*
/obj/machinery/atmospherics/pipe/simple/hide(i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()

/obj/machinery/atmospherics/pipe/simple/pipeline_expansion()
	return list(node1, node2)

/obj/machinery/atmospherics/pipe/simple/update_node_icon()
	..()
	if(node1)
		node1.update_icon()
	if(node2)
		node2.update_icon()
*/
//Colored pipes, use these for mapping
/obj/machinery/atmospherics/pipe/simple/general
	name="pipe"

/obj/machinery/atmospherics/pipe/simple/general/visible
	level = 2

/obj/machinery/atmospherics/pipe/simple/general/hidden
	level = 1

/obj/machinery/atmospherics/pipe/simple/scrubbers
	name="scrubbers pipe"
	pipe_color=rgb(255,0,0)
	color=rgb(255,0,0)

/obj/machinery/atmospherics/pipe/simple/scrubbers/visible
	level = 2

/obj/machinery/atmospherics/pipe/simple/scrubbers/hidden
	level = 1

/obj/machinery/atmospherics/pipe/simple/supply
	name="air supply pipe"
	pipe_color=rgb(0,0,255)
	color=rgb(0,0,255)

/obj/machinery/atmospherics/pipe/simple/supply/visible
	level = 2

/obj/machinery/atmospherics/pipe/simple/supply/hidden
	level = 1

/obj/machinery/atmospherics/pipe/simple/supplymain
	name="main air supply pipe"
	pipe_color=rgb(130,43,272)
	color=rgb(130,43,272)

/obj/machinery/atmospherics/pipe/simple/supplymain/visible
	level = 2

/obj/machinery/atmospherics/pipe/simple/supplymain/hidden
	level = 1

/obj/machinery/atmospherics/pipe/simple/yellow
	pipe_color=rgb(255,198,0)
	color=rgb(255,198,0)

/obj/machinery/atmospherics/pipe/simple/yellow/visible
	level = 2

/obj/machinery/atmospherics/pipe/simple/yellow/hidden
	level = 1

/obj/machinery/atmospherics/pipe/simple/cyan
	pipe_color=rgb(0,256,249)
	color=rgb(0,256,249)

/obj/machinery/atmospherics/pipe/simple/cyan/visible
	level = 2

/obj/machinery/atmospherics/pipe/simple/cyan/hidden
	level = 1

/obj/machinery/atmospherics/pipe/simple/green
	pipe_color=rgb(30,256,0)
	color=rgb(30,256,0)

/obj/machinery/atmospherics/pipe/simple/green/visible
	level = 2

/obj/machinery/atmospherics/pipe/simple/green/hidden
	level = 1
