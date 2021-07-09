//3-Way Manifold

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold
	icon = 'icons/obj/atmospherics/pipes/he-manifold.dmi'
	icon_state = "manifold-3"

	name = "pipe manifold"
	desc = "A manifold composed of regular pipes."

	dir = SOUTH
	initialize_directions = EAST|NORTH|WEST

	device_type = TRINARY

	construction_type = /obj/item/pipe/trinary
	pipe_state = "he_manifold"

	///List of cached overlays of the middle part indexed by piping layer
	var/static/list/mutable_appearance/center_cache = list()

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold/New()
	icon_state = ""
	return ..()

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold/SetInitDirections()
	initialize_directions = ALL_CARDINALS
	initialize_directions &= ~dir

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold/update_overlays()
	. = ..()
	var/mutable_appearance/center = center_cache["[piping_layer]"]
	if(!center)
		center = mutable_appearance(icon, "manifold_center")
		PIPING_LAYER_DOUBLE_SHIFT(center, piping_layer)
		center_cache["[piping_layer]"] = center
	. += center

	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(nodes[i])
			. += getpipeimage(icon, "pipe-[piping_layer]", get_dir(src, nodes[i]))

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold/layer2
	piping_layer = 2
	icon_state = "manifold-2"

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold/layer4
	piping_layer = 4
	icon_state = "manifold-4"
