/// This is an atmospherics pipe which can relay air up/down a deck.
/obj/machinery/atmospherics/pipe/multiz
	name = "multi deck pipe adapter"
	desc = "An adapter which allows pipes to connect to other pipenets on different decks."
	icon_state = "adapter-3"
	icon = 'icons/obj/atmospherics/pipes/multiz.dmi'

	dir = SOUTH
	initialize_directions = SOUTH

	layer = HIGH_OBJ_LAYER
	device_type = UNARY
	paintable = FALSE

	construction_type = /obj/item/pipe/directional
	pipe_state = "multiz"

	///Our central icon
	var/mutable_appearance/center = null
	///The pipe icon
	var/mutable_appearance/pipe = null
	///Reference to the node
	var/obj/machinery/atmospherics/front_node = null

/* We use New() instead of Initialize() because these values are used in update_icon()
 * in the mapping subsystem init before Initialize() is called in the atoms subsystem init.
 * This is true for the other manifolds (the 4 ways and the heat exchanges) too.
 */
/obj/machinery/atmospherics/pipe/multiz/New()
	icon_state = ""
	center = mutable_appearance(icon, "adapter_center", layer = HIGH_OBJ_LAYER)
	pipe = mutable_appearance(icon, "pipe-[piping_layer]")
	return ..()

/obj/machinery/atmospherics/pipe/multiz/set_init_directions()
	initialize_directions = dir

/obj/machinery/atmospherics/pipe/multiz/update_layer()
	return // Noop because we're moving this to /obj/machinery/atmospherics/pipe

/obj/machinery/atmospherics/pipe/multiz/update_overlays()
	. = ..()
	pipe.color = front_node ? front_node.pipe_color : rgb(255, 255, 255)
	pipe.icon_state = "pipe-[piping_layer]"
	. += pipe
	center.pixel_x = PIPING_LAYER_P_X * (piping_layer - PIPING_LAYER_DEFAULT)
	. += center

///Attempts to locate a multiz pipe that's above us, if it finds one it merges us into its pipenet
/obj/machinery/atmospherics/pipe/multiz/pipeline_expansion()
	var/turf/local_turf = get_turf(src)
	for(var/obj/machinery/atmospherics/pipe/multiz/above in SSmapping.get_turf_above(local_turf))
		if(!is_connectable(above, piping_layer))
			continue
		nodes += above
		above.nodes += src //Two way travel :)
	for(var/obj/machinery/atmospherics/pipe/multiz/below in SSmapping.get_turf_below(local_turf))
		if(!is_connectable(below, piping_layer))
			continue
		below.pipeline_expansion() //If we've got one below us, force it to add us on facebook
	return ..()
