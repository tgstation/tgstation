/*
Simple Pipe
The regular pipe you see everywhere, including bent ones.
*/

/obj/machinery/atmospherics/pipe/simple
	icon = 'icons/obj/atmospherics/pipes/simple.dmi'
	icon_state = "intact"

	name = "pipe"
	desc = "A one meter section of regular pipe"

	dir = SOUTH
	initialize_directions = SOUTH|NORTH

	device_type = BINARY

/obj/machinery/atmospherics/pipe/simple/SetInitDirections()
	if(dir in diagonals)
		initialize_directions = dir
	switch(dir)
		if(NORTH,SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST,WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/simple/atmosinit()
	normalize_dir()
	..()

/obj/machinery/atmospherics/pipe/simple/proc/normalize_dir()
	if(dir==SOUTH)
		setDir(NORTH)
	else if(dir==WEST)
		setDir(EAST)

/obj/machinery/atmospherics/pipe/simple/update_icon()
	normalize_dir()
	..()

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
