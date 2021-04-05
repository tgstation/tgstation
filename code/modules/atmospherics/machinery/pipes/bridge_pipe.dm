/obj/machinery/atmospherics/pipe/bridge_pipe
	icon = 'icons/obj/atmospherics/pipes/bridge_pipe.dmi'
	icon_state = "bridge_center"

	name = "bridge pipe"
	desc = "A one meter section of regular pipe used to connect pipenets over pipes."

	dir = SOUTH
	initialize_directions = NORTH | SOUTH
	pipe_flags = PIPING_CARDINAL_AUTONORMALIZE | PIPING_BRIDGE
	device_type = BINARY

	construction_type = /obj/item/pipe/binary
	pipe_state = "bridge_center"

	var/static/list/mutable_appearance/center_cache = list()

/obj/machinery/atmospherics/pipe/bridge_pipe/Initialize()
	icon_state = ""
	. = ..()

/obj/machinery/atmospherics/pipe/bridge_pipe/SetInitDirections()
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/bridge_pipe/update_overlays()
	. = ..()
	var/mutable_appearance/center = center_cache["[piping_layer]"]
	if(!center)
		center = mutable_appearance(icon, "bridge_center")
		PIPING_LAYER_DOUBLE_SHIFT(center, piping_layer)
		center_cache["[piping_layer]"] = center
	. += center

	layer = HIGH_PIPE_LAYER //to stay above all sorts of pipes

	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(!nodes[i])
			continue
		var/image/pipe = getpipeimage('icons/obj/atmospherics/pipes/manifold.dmi', "pipe-[piping_layer]", get_dir(src, nodes[i]))
		PIPING_LAYER_DOUBLE_SHIFT(pipe, piping_layer)
		pipe.layer = layer + 0.01
		. += pipe
