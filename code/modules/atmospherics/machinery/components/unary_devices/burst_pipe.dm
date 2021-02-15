/obj/machinery/atmospherics/components/unary/burstpipe
	icon_state = "burst_pipe"

	name = "exploded pipe"
	desc = "It is an exploded pipe."

	layer = GAS_SCRUBBER_LAYER
	showpipe = FALSE

/obj/machinery/atmospherics/components/unary/burstpipe/Initialize(mapload, set_dir, set_piping_layer)
	. = ..()
	dir = set_dir
	piping_layer = set_piping_layer
	PIPING_LAYER_SHIFT(src, piping_layer)
	initialize_directions = dir
	var/obj/machinery/atmospherics/node = nodes[1]
	atmosinit()
	if(node)
		node.atmosinit()
		node.addMember(src)
	SSair.add_to_rebuild_queue(src)

/obj/machinery/atmospherics/components/unary/burstpipe/process_atmos()
	if(!parents)
		return
	var/datum/gas_mixture/external = loc.return_air()
	var/datum/gas_mixture/internal = parents[1].air

	if(internal.release_gas_to(external, INFINITY))
		air_update_turf(FALSE, FALSE)
		update_parents()

/obj/machinery/atmospherics/components/unary/burstpipe/wrench_act(mob/user, obj/item/I)
	to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")
	if (I.use_tool(src, user, 40, volume=50))
		user.visible_message(
			"[user] unfastens \the [src].",
			"<span class='notice'>You unfasten \the [src].</span>")
		qdel(src)

/obj/machinery/atmospherics/components/unary/burstpipe/can_crawl_through()
	return TRUE