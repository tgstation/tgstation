/*
3-Way Manifold
*/
/obj/machinery/atmospherics/pipe/manifold
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold"

	name = "pipe manifold"
	desc = "A manifold composed of regular pipes"

	dir = SOUTH
	initialize_directions = EAST|NORTH|WEST

	device_type = TRINARY

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

/obj/machinery/atmospherics/pipe/manifold/update_icon()
	var/invis = invisibility ? "-f" : ""

	icon_state = "manifold_center[invis]"

	cut_overlays()

	//Add non-broken pieces
	for(DEVICE_TYPE_LOOP)
		if(NODE_I)
			add_overlay(getpipeimage('icons/obj/atmospherics/pipes/manifold.dmi', "manifold_full[invis]", get_dir(src, NODE_I)))

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
