/obj/machinery/atmospherics/pipe/layer_manifold
	name = "pipe-layer manifold"
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifoldlayer"
	desc = "A special pipe to bridge pipe layers with."
	dir = SOUTH
	initialize_directions = NORTH|SOUTH
	volume = 260 //6 averaged pipe segments
	pipe_flags = ALL_LAYER
	var/list/front_nodes = list()
	var/list/back_nodes = list()
	piping_layer = PIPING_LAYER_DEFAULT

/obj/machinery/atmospherics/pipe/layer_manifold/SetInitDirections()
	switch(dir)
		if(NORTH || SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST || WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/layer_manifold/New()
	for(var/pipelayer = PIPING_LAYER_MIN; pipelayer <= PIPING_LAYER_MAX; pipelayer += 1)
		front_nodes.Add(null)
		back_nodes.Add(null)
	..()

/obj/machinery/atmospherics/pipe/layer_manifold/setPipingLayer(new_layer = PIPING_LAYER_DEFAULT)
	piping_layer = PIPING_LAYER_DEFAULT

/obj/machinery/atmospherics/pipe/layer_manifold/atmosinit()
	findAllConnections(dir)
	..()

/obj/machinery/atmospherics/pipe/layer_manifold/on_construction()
	findAllConnections(dir)
	for(var/obj/machinery/atmospherics/node in (front_nodes + back_nodes))
		node.Initialize()
		node.atmosinit()
		node.build_network()
	. = ..()

/obj/machinery/atmospherics/pipe/layer_manifold/pipeline_expansion()
	findAllConnections(dir)
	return front_nodes + back_nodes

/obj/machinery/atmospherics/pipe/layer_manifold/Destroy()
	for(var/obj/machinery/atmospherics/node in (front_nodes + back_nodes))
		node.disconnect(src)
	..()

/obj/machinery/atmospherics/pipe/layer_manifold/disconnect(obj/machinery/atmospherics/reference)
	for(var/pipelayer = PIPING_LAYER_MIN; pipelayer <= PIPING_LAYER_MAX; pipelayer += 1)
		if(reference == front_nodes[pipelayer])
			if(istype(front_nodes[pipelayer], /obj/machinery/atmospherics/pipe))
				var/obj/machinery/atmospherics/pipe/PL = front_nodes[pipelayer]
				qdel(PL.parent)
			front_nodes[pipelayer] = null
		if(reference == back_nodes[pipelayer])
			if(istype(back_nodes[pipelayer], /obj/machinery/atmospherics/pipe))
				var/obj/machinery/atmospherics/pipe/PL = back_nodes[pipelayer]
				qdel(PL.parent)
			back_nodes[pipelayer] = null
	..()

/obj/machinery/atmospherics/pipe/layer_manifold/update_icon()
	var/invis = invisibility ? "-f" : ""
	icon_state = "[initial(icon_state)][invis]"
	overlays.Cut()
	for(var/pipelayer = PIPING_LAYER_MIN; pipelayer <= PIPING_LAYER_MAX; pipelayer += 1)
		if(front_nodes[pipelayer]) //we are connected at this layer
			var/layer_diff = pipelayer - PIPING_LAYER_DEFAULT
			var/image/I = getpipeimage('icons/obj/atmospherics/pipes/manifold.dmi', "manifold_full[invis]", get_dir(src, front_nodes[pipelayer]))
			switch(dir)
				if(NORTH)
					I.pixel_x = layer_diff * PIPING_LAYER_P_X
					I.pixel_y = 4
				if(SOUTH)
					I.pixel_x = layer_diff * PIPING_LAYER_P_X
					I.pixel_y = -4
				if(EAST)
					I.pixel_y = layer_diff * PIPING_LAYER_P_Y
					I.pixel_x = 4
				if(WEST)
					I.pixel_y = layer_diff * PIPING_LAYER_P_Y
					I.pixel_x = -4
			add_overlay(I)
		if(back_nodes[pipelayer])
			var/layer_diff = pipelayer - PIPING_LAYER_DEFAULT
			var/image/I = getpipeimage('icons/obj/atmospherics/pipes/manifold.dmi', "manifold_full[invis]", get_dir(src, back_nodes[pipelayer]))
			switch(dir)
				if(NORTH)
					I.pixel_x = layer_diff * PIPING_LAYER_P_X
					I.pixel_y = -4
				if(SOUTH)
					I.pixel_x = layer_diff * PIPING_LAYER_P_X
					I.pixel_y = 4
				if(EAST)
					I.pixel_y = layer_diff * PIPING_LAYER_P_Y
					I.pixel_x = -4
				if(WEST)
					I.pixel_y = layer_diff * PIPING_LAYER_P_Y
					I.pixel_x = 4
			add_overlay(I)

/obj/machinery/atmospherics/pipe/layer_manifold/Initialize(mapload)
	findAllConnections(initialize_directions)
	update_icon()
	..()

/obj/machinery/atmospherics/pipe/layer_manifold/proc/findAllConnections(d)
	for(var/iter = PIPING_LAYER_MIN; iter <= PIPING_LAYER_MAX; iter += 1)
		var/obj/machinery/atmospherics/foundfront
		var/obj/machinery/atmospherics/foundback
		foundfront = findConnecting(dir, iter)
		foundback = findConnecting(turn(dir, 180), iter)
		front_nodes[iter] = foundfront
		back_nodes[iter] = foundback
	update_icon()

/obj/machinery/atmospherics/pipe/layer_manifold/relaymove(mob/living/user, dir)
	if(initialize_directions & dir)
		return ..()
	if((NORTH|EAST) & dir)
		user.ventcrawl_layer = Clamp(user.ventcrawl_layer + 1, PIPING_LAYER_MIN, PIPING_LAYER_MAX)
	if((SOUTH|WEST) & dir)
		user.ventcrawl_layer = Clamp(user.ventcrawl_layer - 1, PIPING_LAYER_MIN, PIPING_LAYER_MAX)
	user << "You align yourself with the [user.ventcrawl_layer]\th output."

