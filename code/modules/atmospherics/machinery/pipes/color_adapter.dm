/obj/machinery/atmospherics/pipe/color_adapter
	icon = 'icons/obj/pipes_n_cables/color_adapter.dmi'
	icon_state = "adapter_map-3"

	name = "color adapter"
	desc = "A one meter section of regular pipe used to connect different colored pipes."

	dir = SOUTH
	initialize_directions = NORTH | SOUTH
	pipe_flags = PIPING_CARDINAL_AUTONORMALIZE | PIPING_ALL_COLORS | PIPING_BRIDGE
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
		var/applied_color = nodes[i].pipe_color
		var/node_dir = get_dir(src, nodes[i])
		if (istype(nodes[i], /obj/machinery/atmospherics/pipe/color_adapter) && ((node_dir & (SOUTH|EAST)) || nodes[i].pipe_color == ATMOS_COLOR_OMNI) && pipe_color != ATMOS_COLOR_OMNI)
			applied_color = pipe_color
		var/image/pipe = get_pipe_image('icons/obj/pipes_n_cables/manifold.dmi', "pipe-3", node_dir, applied_color)
		pipe.appearance_flags |= RESET_COLOR|KEEP_APART
		PIPING_LAYER_DOUBLE_SHIFT(pipe, piping_layer)
		pipe.layer = layer + 0.01
		. += pipe

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
