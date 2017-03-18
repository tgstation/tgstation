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
	device_type = BINARY

/obj/machinery/atmospherics/pipe/layer_manifold/proc/nullifyAllNodes()
	for(var/obj/machinery/atmospherics/A in front_nodes)
		A.disconnect(src)
		front_nodes[A] = null
		if(A)
			A.build_network()
	for(var/obj/machinery/atmospherics/A in back_nodes)
		A.disconnect(src)
		back_nodes[A] = null
		if(A)
			A.build_network()
	for(var/obj/machinery/atmospherics/A in nodes)
		A.disconnect(src)
		nodes[A] = null
		if(A)
			A.build_network()

/obj/machinery/atmospherics/pipe/layer_manifold/Destroy()
	nullifyAllNodes()
	..()

/obj/machinery/atmospherics/pipe/layer_manifold/depipeline()
	build_network()	//WE WILL SURVIVE!
	..()

/*
/obj/machinery/atmospherics/pipe/layer_manifold/update_icon()
	var/invis = invisibility ? "-f" : ""
	icon_state = "[initial(icon_state)][invis]"
	overlays.Cut()
	for(var/pipelayer = PIPING_LAYER_MIN; pipelayer <= PIPING_LAYER_MAX; pipelayer += 1)
		if(front_nodes[pipelayer]) //we are connected at this layer
			var/layer_diff = pipelayer - PIPING_LAYER_DEFAULT
			var/image/I = getpipeimage('icons/obj/atmospherics/pipes/manifold.dmi', "manifold_full[invis]", get_dir(src, front_nodes[pipelayer]))
			I.pixel_x = layer_diff * PIPING_LAYER_P_X
			I.pixel_y = layer_diff * PIPING_LAYER_P_Y
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
*/

/obj/machinery/atmospherics/pipe/layer_manifold/SetInitDirections()
	switch(dir)
		if(NORTH || SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST || WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/layer_manifold/proc/findAllConnections()
	front_nodes = list()
	back_nodes = list()
	var/list/new_nodes = list()
	for(var/iter = PIPING_LAYER_MIN; iter <= PIPING_LAYER_MAX; iter += 1)
		var/obj/machinery/atmospherics/foundfront = findConnecting(dir, iter)
		var/obj/machinery/atmospherics/foundback = findConnecting(turn(dir, 180), iter)
		front_nodes += foundfront
		back_nodes += foundback
		if(foundfront)
			new_nodes += foundfront
		if(foundback)
			new_nodes += foundback
	update_icon()
	return new_nodes

/obj/machinery/atmospherics/pipe/layer_manifold/addMember()
	build_network()
	. = ..()

/obj/machinery/atmospherics/pipe/layer_manifold/return_air()
	build_network()
	. = ..()

/obj/machinery/atmospherics/pipe/layer_manifold/setPipingLayer(new_layer = PIPING_LAYER_DEFAULT)
	piping_layer = PIPING_LAYER_DEFAULT

/obj/machinery/atmospherics/pipe/layer_manifold/pipeline_expansion()
	return findAllConnections()

/obj/machinery/atmospherics/pipe/layer_manifold/disconnect(obj/machinery/atmospherics/reference)
	if(istype(reference, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = reference
		qdel(P.parent)
	if(reference in nodes)
		var/I = nodes.Find(reference)
		NODE_I = null
	if(reference in front_nodes)
		var/I = front_nodes.Find(reference)
		front_nodes[I] = null
	if(reference in back_nodes)
		var/I = back_nodes.Find(reference)
		back_nodes[I] = null
	if(reference)
		reference.build_network()
	findAllConnections()

/obj/machinery/atmospherics/pipe/layer_manifold/relaymove(mob/living/user, dir)
	if(initialize_directions & dir)
		return ..()
	if((NORTH|EAST) & dir)
		user.ventcrawl_layer = Clamp(user.ventcrawl_layer + 1, PIPING_LAYER_MIN, PIPING_LAYER_MAX)
	if((SOUTH|WEST) & dir)
		user.ventcrawl_layer = Clamp(user.ventcrawl_layer - 1, PIPING_LAYER_MIN, PIPING_LAYER_MAX)
	user << "You align yourself with the [user.ventcrawl_layer]\th output."
