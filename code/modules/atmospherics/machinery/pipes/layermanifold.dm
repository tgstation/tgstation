/obj/machinery/atmospherics/pipe/layer_manifold
	name = "pipe-layer manifold"
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifoldlayer"
	desc = "A special pipe to bridge pipe layers with."
	dir = SOUTH
	initialize_directions = NORTH|SOUTH
	pipe_flags = PIPING_ALL_LAYER | PIPING_DEFAULT_LAYER_ONLY | PIPING_CARDINAL_AUTONORMALIZE
	piping_layer = PIPING_LAYER_DEFAULT
	device_type = 0
	volume = 260
	var/list/front_nodes
	var/list/back_nodes
	construction_type = /obj/item/pipe/binary
	pipe_state = "layer_manifold"

/obj/machinery/atmospherics/pipe/layer_manifold/Initialize()
	front_nodes = list()
	back_nodes = list()
	return ..()

/obj/machinery/atmospherics/pipe/layer_manifold/Destroy()
	nullifyAllNodes()
	return ..()

/obj/machinery/atmospherics/pipe/layer_manifold/proc/nullifyAllNodes()
	var/list/obj/machinery/atmospherics/needs_nullifying = get_all_connected_nodes()
	front_nodes = null
	back_nodes = null
	nodes = list()
	for(var/obj/machinery/atmospherics/A in needs_nullifying)
		A.disconnect(src)
		A.build_network()

/obj/machinery/atmospherics/pipe/layer_manifold/proc/get_all_connected_nodes()
	return front_nodes + back_nodes + nodes

/obj/machinery/atmospherics/pipe/layer_manifold/update_icon()	//HEAVILY WIP FOR UPDATE ICONS!!
	layer = (initial(layer) + (PIPING_LAYER_MAX * PIPING_LAYER_LCHANGE))	//This is above everything else.
	var/invis = invisibility ? "-f" : ""
	icon_state = "[initial(icon_state)][invis]"
	cut_overlays()
	for(var/obj/machinery/atmospherics/A in front_nodes)
		add_attached_image(A)
	for(var/obj/machinery/atmospherics/A in back_nodes)
		add_attached_image(A)

/obj/machinery/atmospherics/pipe/layer_manifold/proc/add_attached_image(obj/machinery/atmospherics/A)
	var/invis = A.invisibility ? "-f" : ""
	if(istype(A, /obj/machinery/atmospherics/pipe/layer_manifold))
		for(var/i = PIPING_LAYER_MIN, i <= PIPING_LAYER_MAX, i++)
			var/image/I = getpipeimage('icons/obj/atmospherics/pipes/manifold.dmi', "manifold_full_layer_long[invis]", get_dir(src, A), A.pipe_color)
			I.pixel_x = (i - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X
			I.pixel_y = (i - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y
			I.layer = layer - 0.01
			add_overlay(I)
	else
		var/image/I = getpipeimage('icons/obj/atmospherics/pipes/manifold.dmi', "manifold_full_layer_long[invis]", get_dir(src, A), A.pipe_color)
		I.pixel_x = A.pixel_x
		I.pixel_y = A.pixel_y
		I.layer = layer - 0.01
		add_overlay(I)

/obj/machinery/atmospherics/pipe/layer_manifold/SetInitDirections()
	switch(dir)
		if(NORTH || SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST || WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/layer_manifold/isConnectable(obj/machinery/atmospherics/target, given_layer)
	if(!given_layer)
		return TRUE
	. = ..()

/obj/machinery/atmospherics/pipe/layer_manifold/proc/findAllConnections()
	front_nodes = list()
	back_nodes = list()
	var/list/new_nodes = list()
	for(var/iter in PIPING_LAYER_MIN to PIPING_LAYER_MAX)
		var/obj/machinery/atmospherics/foundfront = findConnecting(dir, iter)
		var/obj/machinery/atmospherics/foundback = findConnecting(turn(dir, 180), iter)
		front_nodes += foundfront
		back_nodes += foundback
		if(foundfront && !QDELETED(foundfront))
			new_nodes += foundfront
		if(foundback && !QDELETED(foundback))
			new_nodes += foundback
	update_icon()
	return new_nodes

/obj/machinery/atmospherics/pipe/layer_manifold/atmosinit()
	normalize_cardinal_directions()
	findAllConnections()
	var/turf/T = loc			// hide if turf is not intact
	hide(T.intact)

/obj/machinery/atmospherics/pipe/layer_manifold/setPipingLayer()
	piping_layer = PIPING_LAYER_DEFAULT

/obj/machinery/atmospherics/pipe/layer_manifold/pipeline_expansion()
	return get_all_connected_nodes()

/obj/machinery/atmospherics/pipe/layer_manifold/disconnect(obj/machinery/atmospherics/reference)
	if(istype(reference, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = reference
		P.destroy_network()
	while(reference in get_all_connected_nodes())
		if(reference in nodes)
			var/I = nodes.Find(reference)
			NODE_I = null
		if(reference in front_nodes)
			var/I = front_nodes.Find(reference)
			front_nodes[I] = null
		if(reference in back_nodes)
			var/I = back_nodes.Find(reference)
			back_nodes[I] = null
	update_icon()

/obj/machinery/atmospherics/pipe/layer_manifold/relaymove(mob/living/user, dir)
	if(initialize_directions & dir)
		return ..()
	if((NORTH|EAST) & dir)
		user.ventcrawl_layer = Clamp(user.ventcrawl_layer + 1, PIPING_LAYER_MIN, PIPING_LAYER_MAX)
	if((SOUTH|WEST) & dir)
		user.ventcrawl_layer = Clamp(user.ventcrawl_layer - 1, PIPING_LAYER_MIN, PIPING_LAYER_MAX)
	to_chat(user, "You align yourself with the [user.ventcrawl_layer]\th output.")
