/*
Simple Pipe
The regular pipe you see everywhere, including bent ones.
*/

/obj/machinery/atmospherics/pipe/simple
	icon = 'icons/obj/atmospherics/pipes/simple.dmi'
	icon_state = "intact"

	name = "pipe"
	desc = "A one meter section of regular pipe."

	dir = SOUTH
	initialize_directions = SOUTH|NORTH
	pipe_flags = PIPING_CARDINAL_AUTONORMALIZE

	device_type = BINARY

	construction_type = /obj/item/pipe/binary/bendable
	pipe_state = "simple"

/obj/machinery/atmospherics/pipe/simple/SetInitDirections()
	normalize_cardinal_directions()
	if(dir in GLOB.diagonals)
		initialize_directions = dir
	switch(dir)
		if(NORTH,SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST,WEST)
			initialize_directions = EAST|WEST

//Colored pipes, use these for mapping
/obj/machinery/atmospherics/pipe/simple/general

/obj/machinery/atmospherics/pipe/simple/general/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/simple/general/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/general/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/general/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/simple/general/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/general/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y
	
/obj/machinery/atmospherics/pipe/simple/scrubbers
	name="scrubbers pipe"
	pipe_color=rgb(255,0,0)
	color=rgb(255,0,0)

/obj/machinery/atmospherics/pipe/simple/scrubbers/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/simple/scrubbers/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/scrubbers/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y
	
/obj/machinery/atmospherics/pipe/simple/scrubbers/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/simple/scrubbers/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/scrubbers/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y
	
/obj/machinery/atmospherics/pipe/simple/supply
	name="air supply pipe"
	pipe_color=rgb(0,0,255)
	color=rgb(0,0,255)

/obj/machinery/atmospherics/pipe/simple/supply/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/simple/supply/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/supply/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/supply/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/simple/supply/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/supply/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y
	
/obj/machinery/atmospherics/pipe/simple/supplymain
	name="main air supply pipe"
	pipe_color=rgb(130,43,255)
	color=rgb(130,43,255)

/obj/machinery/atmospherics/pipe/simple/supplymain/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/simple/supplymain/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/supplymain/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y
	
/obj/machinery/atmospherics/pipe/simple/supplymain/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/simple/supplymain/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/supplymain/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y
	
/obj/machinery/atmospherics/pipe/simple/yellow
	pipe_color=rgb(255,198,0)
	color=rgb(255,198,0)

/obj/machinery/atmospherics/pipe/simple/yellow/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/simple/yellow/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/yellow/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y
	
/obj/machinery/atmospherics/pipe/simple/yellow/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/simple/yellow/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/yellow/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y
	
/obj/machinery/atmospherics/pipe/simple/cyan
	pipe_color=rgb(0,255,249)
	color=rgb(0,255,249)

/obj/machinery/atmospherics/pipe/simple/cyan/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/simple/cyan/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/cyan/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/cyan/hidden
	level = PIPE_HIDDEN_LEVEL
	
/obj/machinery/atmospherics/pipe/simple/cyan/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/cyan/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/green
	pipe_color=rgb(30,255,0)
	color=rgb(30,255,0)

/obj/machinery/atmospherics/pipe/simple/green/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/simple/green/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/green/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/green/hidden
	level = PIPE_HIDDEN_LEVEL
	
/obj/machinery/atmospherics/pipe/simple/green/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/green/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/orange
	pipe_color=rgb(255,129,25)
	color=rgb(255,129,25)

/obj/machinery/atmospherics/pipe/simple/orange/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/simple/orange/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/orange/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/orange/hidden
	level = PIPE_HIDDEN_LEVEL
	
/obj/machinery/atmospherics/pipe/simple/orange/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/orange/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/purple
	pipe_color=rgb(128,0,182)
	color=rgb(128,0,182)

/obj/machinery/atmospherics/pipe/simple/purple/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/simple/purple/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/purple/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/purple/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/simple/purple/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/purple/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y
	
/obj/machinery/atmospherics/pipe/simple/dark
	pipe_color=rgb(69,69,69)
	color=rgb(69,69,69)

/obj/machinery/atmospherics/pipe/simple/dark/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/simple/dark/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/dark/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/dark/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/simple/dark/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/dark/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y
	
/obj/machinery/atmospherics/pipe/simple/violet
	pipe_color=rgb(64,0,128)
	color=rgb(64,0,128)

/obj/machinery/atmospherics/pipe/simple/violet/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/simple/violet/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/violet/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/violet/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/simple/violet/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/violet/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y
	
/obj/machinery/atmospherics/pipe/simple/brown
	pipe_color=rgb(178,100,56)
	color=rgb(178,100,56)

/obj/machinery/atmospherics/pipe/simple/brown/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/simple/brown/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/brown/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/brown/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/simple/brown/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/brown/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y
