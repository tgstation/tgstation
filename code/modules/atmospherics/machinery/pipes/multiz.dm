/obj/machinery/atmospherics/pipe/simple/multiz
	name = "multi deck pipe adapter"
	desc = "An adapter which allows pipes to connect to other pipenets on different decks."

/obj/machinery/atmospherics/pipe/simple/multiz/update_icon()
	. = ..()
	cut_overlays() //This adds the overlay showing it's a multiz pipe. This should go above turfs and such and really emphasize how it's an UP/ DOWN pipe
	var/image/multiz_overlay_node = new(src) //If we have a firing state, light em up!
	multiz_overlay_node.icon = 'icons/obj/atmos.dmi'
	multiz_overlay_node.icon_state = "multiz_pipe"
	multiz_overlay_node.layer = HIGH_OBJ_LAYER
	add_overlay(multiz_overlay_node)

/obj/machinery/atmospherics/pipe/simple/multiz/pipeline_expansion() //When new pipes are added to a network, this gets called. Nodes is all the pipes this one's connected to. We bruteforce add the pipes above and below us.
	var/turf/T = get_turf(src)
	var/obj/machinery/atmospherics/pipe/simple/multiz/above = locate(/obj/machinery/atmospherics/pipe/simple/multiz) in(SSmapping.get_turf_above(T))
	if(above)
		nodes += above
		above.nodes += src //Two way travel :)
		return ..()
	else
		return ..()