//4-Way Manifold

/obj/machinery/atmospherics/pipe/manifold4w
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold4w-3"

	name = "4-way pipe manifold"
	desc = "A manifold composed of regular pipes."

	initialize_directions = ALL_CARDINALS

	device_type = QUATERNARY

	construction_type = /obj/item/pipe/quaternary
	pipe_state = "manifold4w"

	///List of cached overlays of the middle part indexed by piping layer
	var/static/list/mutable_appearance/center_cache = list()

/obj/machinery/atmospherics/pipe/manifold4w/New()
	icon_state = ""
	return ..()

/obj/machinery/atmospherics/pipe/manifold4w/SetInitDirections()
	initialize_directions = initial(initialize_directions)

/obj/machinery/atmospherics/pipe/manifold4w/update_overlays()
	. = ..()
	var/mutable_appearance/center = center_cache["[piping_layer]"]
	if(!center)
		center = mutable_appearance(icon, "manifold4w_center")
		PIPING_LAYER_DOUBLE_SHIFT(center, piping_layer)
		center_cache["[piping_layer]"] = center
	. += center

	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(nodes[i])
			. += getpipeimage(icon, "pipe-[piping_layer]", get_dir(src, nodes[i]))
	update_layer()
