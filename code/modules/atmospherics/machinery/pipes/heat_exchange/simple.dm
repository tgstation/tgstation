/obj/machinery/atmospherics/pipe/heat_exchanging/simple
	icon_state = "intact"

	name = "pipe"
	desc = "A one meter section of heat-exchanging pipe"

	dir = SOUTH
	initialize_directions_he = SOUTH|NORTH

	device_type = BINARY

/obj/machinery/atmospherics/pipe/heat_exchanging/simple/SetInitDirections()
	if(dir in diagonals)
		initialize_directions_he = dir
	switch(dir)
		if(NORTH,SOUTH)
			initialize_directions_he = SOUTH|NORTH
		if(EAST,WEST)
			initialize_directions_he = WEST|EAST

/obj/machinery/atmospherics/pipe/heat_exchanging/simple/proc/normalize_dir()
	if(dir==SOUTH)
		setDir(NORTH)
	else if(dir==WEST)
		setDir(EAST)

/obj/machinery/atmospherics/pipe/heat_exchanging/simple/atmosinit()
	normalize_dir()
	..()

/obj/machinery/atmospherics/pipe/heat_exchanging/simple/update_icon()
	normalize_dir()
	..()