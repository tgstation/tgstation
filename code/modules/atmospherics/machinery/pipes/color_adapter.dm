/obj/machinery/atmospherics/pipe/color_adapter
	icon = 'icons/obj/pipes_n_cables/color_adapter.dmi'
	icon_state = "adapter_map-3"

	name = "color adapter"
	desc = "A one meter section of regular pipe used to connect different colored pipes."

	dir = SOUTH
	initialize_directions = NORTH | SOUTH
	pipe_flags = PIPING_CARDINAL_AUTONORMALIZE | PIPING_ALL_COLORS | PIPING_BRIDGE | PIPING_DONT_SHARE_COLOR
	device_type = BINARY

	construction_type = /obj/item/pipe/binary
	pipe_state = "adapter_center"

	paintable = FALSE
	hide = FALSE

	has_gas_visuals = FALSE

	///cache for the icons
	var/static/list/mutable_appearance/center_cache = list()

/obj/machinery/atmospherics/pipe/color_adapter/Initialize(mapload)
	icon_state = ""
	. = ..()

/obj/machinery/atmospherics/pipe/color_adapter/set_init_directions()
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/color_adapter/update_overlays()
	. = ..()
	var/mutable_appearance/center = center_cache["[piping_layer]"]
	if(!center)
		center = mutable_appearance(initial(icon), "adapter_center")
		PIPING_LAYER_DOUBLE_SHIFT(center, piping_layer)
		center_cache["[piping_layer]"] = center
	. += center

	update_layer()

	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(!nodes[i])
			continue
		var/node_dir = get_dir(src, nodes[i])
		var/image/pipe = get_pipe_image('icons/obj/pipes_n_cables/manifold.dmi', "pipe-3", node_dir, get_node_color(nodes[i], node_dir))
		pipe.appearance_flags |= RESET_COLOR|KEEP_APART
		PIPING_LAYER_DOUBLE_SHIFT(pipe, piping_layer)
		pipe.layer = layer + 0.01
		. += pipe

/obj/machinery/atmospherics/pipe/color_adapter/proc/get_node_color(obj/machinery/atmospherics/node, node_dir = get_dir(src, node))
	// If we are omni always use input color
	if(pipe_color == ATMOS_COLOR_OMNI)
		return node.pipe_color

	// If we are connecting to a non-sharer (like another color adapter)
	if(node.pipe_flags & PIPING_DONT_SHARE_COLOR)
		// Use our own color if the other node is omni
		if(node.pipe_color == ATMOS_COLOR_OMNI)
			return pipe_color
		// South/east are prioritized, so it doesn't change based on update order
		if(node_dir & (SOUTH|EAST))
			return pipe_color

	// Otherwise just use the node's color
	return node.pipe_color

/obj/machinery/atmospherics/pipe/color_adapter/layer1
	icon_state = "adapter_map-1"
	piping_layer = 1

/obj/machinery/atmospherics/pipe/color_adapter/layer2
	icon_state = "adapter_map-2"
	piping_layer = 2

/obj/machinery/atmospherics/pipe/color_adapter/layer4
	icon_state = "adapter_map-4"
	piping_layer = 4

/obj/machinery/atmospherics/pipe/color_adapter/layer5
	icon_state = "adapter_map-5"
	piping_layer = 5
