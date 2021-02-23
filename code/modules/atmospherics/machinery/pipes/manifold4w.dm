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

	var/mutable_appearance/center

/obj/machinery/atmospherics/pipe/manifold4w/New()
	icon_state = ""
	center = mutable_appearance(icon, "manifold4w_center")
	return ..()

/obj/machinery/atmospherics/pipe/manifold4w/SetInitDirections()
	initialize_directions = initial(initialize_directions)

/obj/machinery/atmospherics/pipe/manifold4w/update_overlays()
	. = ..()
	cut_overlays()
	if(!center)
		center = mutable_appearance(icon, "manifold_center")
	PIPING_LAYER_DOUBLE_SHIFT(center, piping_layer)
	. += center

	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(nodes[i])
			. += getpipeimage(icon, "pipe-[piping_layer]", get_dir(src, nodes[i]))

/obj/machinery/atmospherics/pipe/manifold4w/reinforced
	name = "4-way reinforced manifold"
	desc = "A manifold composed of reinforced pipes."
	can_burst = FALSE
	var/mutable_appearance/reinforced

/obj/machinery/atmospherics/pipe/manifold4w/reinforced/update_overlays()
	. = ..()
	cut_overlays()
	if(!reinforced)
		reinforced = mutable_appearance(icon, "reinforced_4w")
	PIPING_LAYER_DOUBLE_SHIFT(reinforced, piping_layer)
	. += reinforced
	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(nodes[i])
			. += getpipeimage(icon, "pipe-[piping_layer]", get_dir(src, nodes[i]))
