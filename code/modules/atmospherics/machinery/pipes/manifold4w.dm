/*
4-way manifold
*/
/obj/machinery/atmospherics/pipe/manifold4w
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold4w"

	name = "4-way pipe manifold"
	desc = "A manifold composed of regular pipes"

	initialize_directions = NORTH|SOUTH|EAST|WEST

	device_type = QUATERNARY

/obj/machinery/atmospherics/pipe/manifold4w/SetInitDirections()
	initialize_directions = initial(initialize_directions)

/obj/machinery/atmospherics/pipe/manifold4w/update_icon()
	var/invis = invisibility ? "-f" : ""

	icon_state = "manifold4w_center[invis]"

	cut_overlays()

	//Add non-broken pieces
	for(DEVICE_TYPE_LOOP)
		if(NODE_I)
			add_overlay(getpipeimage('icons/obj/atmospherics/pipes/manifold.dmi', "manifold_full[invis]", get_dir(src, NODE_I)))

//Colored pipes, use these for mapping
/obj/machinery/atmospherics/pipe/manifold4w/general

/obj/machinery/atmospherics/pipe/manifold4w/general/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/general/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/manifold4w/scrubbers
	name="scrubbers pipe"
	pipe_color=rgb(255,0,0)
	color=rgb(255,0,0)

/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER


/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/manifold4w/supply
	name="air supply pipe"
	pipe_color=rgb(0,0,255)
	color=rgb(0,0,255)

/obj/machinery/atmospherics/pipe/manifold4w/supply/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/supply/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/manifold4w/supplymain
	name="main air supply pipe"
	pipe_color=rgb(130,43,272)
	color=rgb(130,43,272)

/obj/machinery/atmospherics/pipe/manifold4w/supplymain/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/supplymain/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/manifold4w/yellow
	pipe_color=rgb(255,198,0)
	color=rgb(255,198,0)

/obj/machinery/atmospherics/pipe/manifold4w/yellow/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/yellow/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/manifold4w/cyan
	pipe_color=rgb(0,256,249)
	color=rgb(0,256,249)

/obj/machinery/atmospherics/pipe/manifold4w/cyan/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/cyan/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/manifold4w/green
	pipe_color=rgb(30,256,0)
	color=rgb(30,256,0)

/obj/machinery/atmospherics/pipe/manifold4w/green/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/green/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/manifold4w/orange
	pipe_color=rgb(255,129,25)
	color=rgb(255,129,25)

/obj/machinery/atmospherics/pipe/manifold4w/orange/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/orange/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/manifold4w/purple
	pipe_color=rgb(128,0,182)
	color=rgb(128,0,182)

/obj/machinery/atmospherics/pipe/manifold4w/purple/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/purple/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/manifold4w/dark
	pipe_color=rgb(69,69,69)
	color=rgb(69,69,69)

/obj/machinery/atmospherics/pipe/manifold4w/dark/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/dark/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/manifold4w/violet
	pipe_color=rgb(64,0,128)
	color=rgb(64,0,128)

/obj/machinery/atmospherics/pipe/manifold4w/violet/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/violet/hidden
	level = PIPE_HIDDEN_LEVEL

/obj/machinery/atmospherics/pipe/manifold4w/brown
	pipe_color=rgb(178,100,56)
	color=rgb(178,100,56)

/obj/machinery/atmospherics/pipe/manifold4w/brown/visible
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/brown/hidden
	level = PIPE_HIDDEN_LEVEL