//3-Way Manifold

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold
	icon = 'icons/obj/atmospherics/pipes/he-manifold.dmi'
	icon_state = "manifold-3"
	base_icon_state = "manifold"

	name = "pipe manifold"
	desc = "A manifold composed of regular pipes."

	dir = SOUTH
	initialize_directions = EAST|NORTH|WEST

	device_type = TRINARY

	construction_type = /obj/item/pipe/trinary
	pipe_state = "he_manifold"

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold/set_init_directions()
	initialize_directions = ALL_CARDINALS
	initialize_directions &= ~dir

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold/update_pipe_icon()
	icon_state = "[base_icon_state]-[piping_layer]"

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold/update_overlays()
	. = ..()
	var/mutable_appearance/center = mutable_appearance(icon, "manifold_center")
	PIPING_LAYER_DOUBLE_SHIFT(center, piping_layer)

	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(nodes[i])
			. += get_pipe_image(icon, "pipe-[piping_layer]", get_dir(src, nodes[i]))

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold/layer2
	piping_layer = 2
	icon_state = "manifold-2"

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold/layer4
	piping_layer = 4
	icon_state = "manifold-4"
