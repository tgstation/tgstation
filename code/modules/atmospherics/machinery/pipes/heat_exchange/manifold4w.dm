//4-Way Manifold

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w
	icon = 'icons/obj/atmospherics/pipes/he-manifold.dmi'
	icon_state = "manifold4w-3"

	name = "4-way pipe manifold"
	desc = "A manifold composed of heat-exchanging pipes."

	initialize_directions = ALL_CARDINALS

	device_type = QUATERNARY

	construction_type = /obj/item/pipe/quaternary
	pipe_state = "he_manifold4w"

	var/mutable_appearance/center

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w/New()
	icon_state = ""
	center = mutable_appearance(icon, "manifold4w_center")
	return ..()

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w/SetInitDirections()
	initialize_directions = initial(initialize_directions)

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w/update_icon()
	cut_overlays()

	PIPING_LAYER_DOUBLE_SHIFT(center, piping_layer)
	add_overlay(center)

	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(nodes[i])
			add_overlay( getpipeimage(icon, "pipe-[piping_layer]", get_dir(src, nodes[i])) )

	update_layer()

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w/layer2
	piping_layer = 2
	icon_state = "manifold4w-2"

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w/layer4
	piping_layer = 4
	icon_state = "manifold4w-4"
