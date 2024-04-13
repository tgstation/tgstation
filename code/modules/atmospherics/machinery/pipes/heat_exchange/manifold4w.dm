//4-Way Manifold

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w
	icon = 'icons/obj/pipes_n_cables/he-manifold.dmi'
	icon_state = "manifold4w-3"
	base_icon_state = "manifold4w"

	name = "4-way pipe manifold"
	desc = "A manifold composed of heat-exchanging pipes."

	initialize_directions = ALL_CARDINALS

	device_type = QUATERNARY

	construction_type = /obj/item/pipe/quaternary
	pipe_state = "he_manifold4w"

	has_gas_visuals = FALSE

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w/set_init_directions()
	initialize_directions = initial(initialize_directions)

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w/update_pipe_icon()
	icon_state = "[base_icon_state]-[piping_layer]"

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w/update_overlays()
	. = ..()
	var/mutable_appearance/center = mutable_appearance(icon, "manifold4w_center")
	PIPING_LAYER_DOUBLE_SHIFT(center, piping_layer)
	. += center

	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(nodes[i])
			. += get_pipe_image(icon, "pipe-[piping_layer]", get_dir(src, nodes[i]))
	update_layer()

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w/layer2
	piping_layer = 2
	icon_state = "manifold4w-2"

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w/layer4
	piping_layer = 4
	icon_state = "manifold4w-4"
