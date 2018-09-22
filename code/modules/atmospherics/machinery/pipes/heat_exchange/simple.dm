/obj/machinery/atmospherics/pipe/heat_exchanging/simple
	icon_state = "intact"

	name = "pipe"
	desc = "A one meter section of heat-exchanging pipe."

	dir = SOUTH
	initialize_directions = SOUTH|NORTH

	device_type = BINARY

	construction_type = /obj/item/pipe/binary/bendable
	pipe_state = "he"

/obj/machinery/atmospherics/pipe/heat_exchanging/simple/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/heat_exchanging/simple/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/heat_exchanging/simple/SetInitDirections()
	if(dir in GLOB.diagonals)
		initialize_directions = dir
	switch(dir)
		if(NORTH,SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST,WEST)
			initialize_directions = WEST|EAST

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
