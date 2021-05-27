/obj/machinery/atmospherics/pipe/layer_manifold
	name = "layer adaptor"
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifoldlayer"
	desc = "A special pipe to bridge pipe layers with."
	dir = SOUTH
	initialize_directions = NORTH|SOUTH
	pipe_flags = PIPING_ALL_LAYER | PIPING_DEFAULT_LAYER_ONLY | PIPING_CARDINAL_AUTONORMALIZE | PIPING_BRIDGE
	piping_layer = PIPING_LAYER_DEFAULT
	device_type = 0
	volume = 260
	construction_type = /obj/item/pipe/binary
	pipe_state = "manifoldlayer"
	paintable = TRUE

	var/list/front_nodes
	var/list/back_nodes

/obj/machinery/atmospherics/pipe/layer_manifold/Initialize()
	front_nodes = list()
	back_nodes = list()
	icon_state = "manifoldlayer_center"
	return ..()

/obj/machinery/atmospherics/pipe/layer_manifold/Destroy()
	nullifyAllNodes()
	return ..()

/obj/machinery/atmospherics/pipe/layer_manifold/proc/nullifyAllNodes()
	for(var/obj/machinery/atmospherics/A in nodes)
		A.disconnect(src)
		SSair.add_to_rebuild_queue(A)
	front_nodes = null
	back_nodes = null
	nodes = list()

/obj/machinery/atmospherics/pipe/layer_manifold/update_layer()
	layer = initial(layer) + (PIPING_LAYER_MAX * PIPING_LAYER_LCHANGE) //This is above everything else.

/obj/machinery/atmospherics/pipe/layer_manifold/update_overlays()
	. = ..()

	for(var/node in front_nodes)
		. += get_attached_images(node)
	for(var/node in back_nodes)
		. += get_attached_images(node)

/obj/machinery/atmospherics/pipe/layer_manifold/proc/get_attached_images(obj/machinery/atmospherics/A)
	if(!A)
		return

	. = list()

	if(istype(A, /obj/machinery/atmospherics/pipe/layer_manifold))
		for(var/i in PIPING_LAYER_MIN to PIPING_LAYER_MAX)
			. += get_attached_image(get_dir(src, A), i, COLOR_VERY_LIGHT_GRAY)
		return
	. += get_attached_image(get_dir(src, A), A.piping_layer, A.pipe_color)

/obj/machinery/atmospherics/pipe/layer_manifold/proc/get_attached_image(p_dir, p_layer, p_color)
	// Uses pipe-3 because we don't want the vertical shifting
	var/image/I = getpipeimage(icon, "pipe-3", p_dir, p_color, p_layer)
	I.layer = layer - 0.01
	return I

/obj/machinery/atmospherics/pipe/layer_manifold/SetInitDirections()
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/layer_manifold/proc/findAllConnections()
	front_nodes = list()
	back_nodes = list()
	nodes = list()
	for(var/iter in PIPING_LAYER_MIN to PIPING_LAYER_MAX)
		var/obj/machinery/atmospherics/foundfront = findConnecting(dir, iter)
		var/obj/machinery/atmospherics/foundback = findConnecting(turn(dir, 180), iter)
		front_nodes += foundfront
		back_nodes += foundback
		if(foundfront && !QDELETED(foundfront))
			nodes += foundfront
		if(foundback && !QDELETED(foundback))
			nodes += foundback
	update_appearance()
	return nodes

/obj/machinery/atmospherics/pipe/layer_manifold/atmosinit()
	normalize_cardinal_directions()
	findAllConnections()

/obj/machinery/atmospherics/pipe/layer_manifold/setPipingLayer()
	piping_layer = PIPING_LAYER_DEFAULT

/obj/machinery/atmospherics/pipe/layer_manifold/pipeline_expansion()
	return nodes

/obj/machinery/atmospherics/pipe/layer_manifold/disconnect(obj/machinery/atmospherics/reference)
	if(istype(reference, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = reference
		P.destroy_network()
	while(reference in nodes)
		var/i = nodes.Find(reference)
		nodes[i] = null
		i = front_nodes.Find(reference)
		if(i)
			front_nodes[i] = null
		i = back_nodes.Find(reference)
		if(i)
			back_nodes[i] = null
	update_appearance()

/obj/machinery/atmospherics/pipe/layer_manifold/relaymove(mob/living/user, direction)
	if(initialize_directions & direction)
		return ..()
	if((NORTH|EAST) & direction)
		user.ventcrawl_layer = clamp(user.ventcrawl_layer + 1, PIPING_LAYER_MIN, PIPING_LAYER_MAX)
	if((SOUTH|WEST) & direction)
		user.ventcrawl_layer = clamp(user.ventcrawl_layer - 1, PIPING_LAYER_MIN, PIPING_LAYER_MAX)
	to_chat(user, "You align yourself with the [user.ventcrawl_layer]\th output.")

/obj/machinery/atmospherics/pipe/layer_manifold/visible
	hide = FALSE
	layer = GAS_PIPE_VISIBLE_LAYER
