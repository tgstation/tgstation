/*
4-way manifold
*/
/obj/machinery/atmospherics/pipe/manifold4w
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold4w"

	name = "4-way pipe manifold"
	desc = "A manifold composed of regular pipes."

	initialize_directions = NORTH|SOUTH|EAST|WEST

	device_type = QUATERNARY

	construction_type = /obj/item/pipe/quaternary
	pipe_state = "manifold4w"

/obj/machinery/atmospherics/pipe/manifold4w/SetInitDirections()
	initialize_directions = initial(initialize_directions)

/obj/machinery/atmospherics/pipe/manifold4w/update_icon()
	var/invis = invisibility ? "-f" : ""

	icon_state = "manifold4w_center[invis]"

	cut_overlays()

	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(nodes[i])
			add_overlay(getpipeimage('icons/obj/atmospherics/pipes/manifold.dmi', "manifold_full[invis]", get_dir(src, nodes[i])))

//Colored pipes, use these for mapping
/obj/machinery/atmospherics/pipe/manifold4w/general

/obj/machinery/atmospherics/pipe/manifold4w/general/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/manifold4w/general/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/general/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/general/hidden
	level = PIPE_HIDDEN_LEVEL
	
/obj/machinery/atmospherics/pipe/manifold4w/general/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/general/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/scrubbers
	name="scrubbers pipe"
	pipe_color=rgb(255,0,0)
	color=rgb(255,0,0)

/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/hidden
	level = PIPE_HIDDEN_LEVEL
	
/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/supply
	name="air supply pipe"
	pipe_color=rgb(0,0,255)
	color=rgb(0,0,255)

/obj/machinery/atmospherics/pipe/manifold4w/supply/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/manifold4w/supply/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/supply/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/supply/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/manifold4w/supply/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/supply/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y
	
/obj/machinery/atmospherics/pipe/manifold4w/supplymain
	name="main air supply pipe"
	pipe_color=rgb(130,43,255)
	color=rgb(130,43,255)

/obj/machinery/atmospherics/pipe/manifold4w/supplymain/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/manifold4w/supplymain/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/supplymain/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/supplymain/hidden
	level = PIPE_HIDDEN_LEVEL
	
/obj/machinery/atmospherics/pipe/manifold4w/supplymain/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/supplymain/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/yellow
	pipe_color=rgb(255,198,0)
	color=rgb(255,198,0)

/obj/machinery/atmospherics/pipe/manifold4w/yellow/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/manifold4w/yellow/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/yellow/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/yellow/hidden
	level = PIPE_HIDDEN_LEVEL
	
/obj/machinery/atmospherics/pipe/manifold4w/yellow/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/yellow/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/cyan
	pipe_color=rgb(0,255,249)
	color=rgb(0,255,249)

/obj/machinery/atmospherics/pipe/manifold4w/cyan/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/manifold4w/cyan/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/cyan/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/cyan/hidden
	level = PIPE_HIDDEN_LEVEL
	
/obj/machinery/atmospherics/pipe/manifold4w/cyan/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/cyan/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/green
	pipe_color=rgb(30,255,0)
	color=rgb(30,255,0)

/obj/machinery/atmospherics/pipe/manifold4w/green/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/manifold4w/green/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/green/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/green/hidden
	level = PIPE_HIDDEN_LEVEL
	
/obj/machinery/atmospherics/pipe/manifold4w/green/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/green/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/orange
	pipe_color=rgb(255,129,25)
	color=rgb(255,129,25)

/obj/machinery/atmospherics/pipe/manifold4w/orange/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/manifold4w/orange/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/orange/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/orange/hidden
	level = PIPE_HIDDEN_LEVEL
	
/obj/machinery/atmospherics/pipe/manifold4w/orange/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/orange/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/purple
	pipe_color=rgb(128,0,182)
	color=rgb(128,0,182)

/obj/machinery/atmospherics/pipe/manifold4w/purple/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/manifold4w/purple/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/purple/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/purple/hidden
	level = PIPE_HIDDEN_LEVEL
	
/obj/machinery/atmospherics/pipe/manifold4w/purple/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/purple/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/dark
	pipe_color=rgb(69,69,69)
	color=rgb(69,69,69)

/obj/machinery/atmospherics/pipe/manifold4w/dark/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/manifold4w/dark/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/dark/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/dark/hidden
	level = PIPE_HIDDEN_LEVEL
	
/obj/machinery/atmospherics/pipe/manifold4w/dark/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/dark/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/violet
	pipe_color=rgb(64,0,128)
	color=rgb(64,0,128)

/obj/machinery/atmospherics/pipe/manifold4w/violet/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/manifold4w/violet/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/violet/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/violet/hidden
	level = PIPE_HIDDEN_LEVEL
	
/obj/machinery/atmospherics/pipe/manifold4w/violet/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/violet/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/brown
	pipe_color=rgb(178,100,56)
	color=rgb(178,100,56)

/obj/machinery/atmospherics/pipe/manifold4w/brown/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	
/obj/machinery/atmospherics/pipe/manifold4w/brown/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/brown/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/brown/hidden
	level = PIPE_HIDDEN_LEVEL
	
/obj/machinery/atmospherics/pipe/manifold4w/brown/hidden/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/manifold4w/brown/hidden/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y
