/obj/machinery/atmospherics/pipe/layer_manifold
	name = "layer adaptor"
	icon = 'icons/obj/pipes_n_cables/manifold.dmi'
	icon_state = "manifoldlayer"
	desc = "A special pipe to bridge pipe layers with."
	dir = SOUTH
	initialize_directions = NORTH|SOUTH
	pipe_flags = PIPING_ALL_LAYER | PIPING_DEFAULT_LAYER_ONLY | PIPING_CARDINAL_AUTONORMALIZE | PIPING_BRIDGE
	piping_layer = PIPING_LAYER_DEFAULT
	device_type = 0
	volume = 200
	construction_type = /obj/item/pipe/binary
	pipe_state = "manifoldlayer"
	paintable = TRUE
	has_gas_visuals = FALSE

	///Reference to all the nodes in the front
	var/list/front_nodes
	///Reference to all the nodes in the back
	var/list/back_nodes

/obj/machinery/atmospherics/pipe/layer_manifold/Initialize(mapload)
	front_nodes = list()
	back_nodes = list()
	icon_state = "manifoldlayer_center"
	return ..()

/obj/machinery/atmospherics/pipe/layer_manifold/Destroy()
	nullify_all_nodes()
	return ..()

/obj/machinery/atmospherics/pipe/layer_manifold/update_pipe_icon()
	return

/obj/machinery/atmospherics/pipe/layer_manifold/proc/nullify_all_nodes()
	for(var/obj/machinery/atmospherics/node in nodes)
		node.disconnect(src)
		SSair.add_to_rebuild_queue(node)
	front_nodes = null
	back_nodes = null
	nodes = list()

/obj/machinery/atmospherics/pipe/layer_manifold/update_layer()
	layer = (HAS_TRAIT(src, TRAIT_UNDERFLOOR) ? BELOW_CATWALK_LAYER : initial(layer)) + (PIPING_LAYER_MAX * PIPING_LAYER_LCHANGE) //This is above everything else.

/obj/machinery/atmospherics/pipe/layer_manifold/update_overlays()
	. = ..()

	for(var/node in front_nodes)
		var/list/front_images = get_attached_images(node)
		if(length(front_images))
			. += front_images
	for(var/node in back_nodes)
		var/list/back_images = get_attached_images(node)
		if(length(back_images))
			. += back_images

/obj/machinery/atmospherics/pipe/layer_manifold/proc/get_attached_images(obj/machinery/atmospherics/machine_check)
	if(!machine_check)
		return

	. = list()

	if(istype(machine_check, /obj/machinery/atmospherics/pipe/layer_manifold))
		for(var/i in PIPING_LAYER_MIN to PIPING_LAYER_MAX)
			. += get_attached_image(get_dir(src, machine_check), i, machine_check.pipe_color == pipe_color ? pipe_color : ATMOS_COLOR_OMNI)
		return
	if(istype(machine_check, /obj/machinery/atmospherics/components/unary/airlock_pump))
		. += get_attached_image(get_dir(src, machine_check), 4, COLOR_BLUE)
		//. += get_attached_image(get_dir(src, machine_check), 2, COLOR_RED) // Only the distro node is added currently to the pipenet, it doesn't merge the pipenet with the waste node
		return
	var/passed_color = machine_check.pipe_color
	if(istype(machine_check, /obj/machinery/atmospherics/pipe/color_adapter) || machine_check.pipe_color == ATMOS_COLOR_OMNI)
		passed_color = pipe_color
	. += get_attached_image(get_dir(src, machine_check), machine_check.piping_layer, passed_color)

/obj/machinery/atmospherics/pipe/layer_manifold/proc/get_attached_image(p_dir, p_layer, p_color)
	var/working_layer = FLOAT_LAYER - HAS_TRAIT(src, TRAIT_UNDERFLOOR) ? 1 : 0.01
	var/mutable_appearance/muta = mutable_appearance('icons/obj/pipes_n_cables/layer_manifold_underlays.dmi', "intact_[p_dir]_[p_layer]", layer = working_layer, appearance_flags = RESET_COLOR|KEEP_APART)
	muta.color = p_color
	return muta

/obj/machinery/atmospherics/pipe/layer_manifold/set_init_directions()
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/layer_manifold/proc/find_all_connections()
	front_nodes = list()
	back_nodes = list()
	nodes = list()
	for(var/iter in PIPING_LAYER_MIN to PIPING_LAYER_MAX)
		var/obj/machinery/atmospherics/foundfront = find_connecting(dir, iter)
		var/obj/machinery/atmospherics/foundback = find_connecting(REVERSE_DIR(dir), iter)
		front_nodes += foundfront
		back_nodes += foundback
		if(foundfront && !QDELETED(foundfront))
			nodes += foundfront
		if(foundback && !QDELETED(foundback))
			nodes += foundback
	update_appearance()
	return nodes

/obj/machinery/atmospherics/pipe/layer_manifold/atmos_init()
	normalize_cardinal_directions()
	find_all_connections()

/obj/machinery/atmospherics/pipe/layer_manifold/set_piping_layer(new_layer)
	piping_layer = PIPING_LAYER_DEFAULT

/obj/machinery/atmospherics/pipe/layer_manifold/pipeline_expansion()
	return nodes

/obj/machinery/atmospherics/pipe/layer_manifold/disconnect(obj/machinery/atmospherics/reference)
	if(istype(reference, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/pipe_reference = reference
		pipe_reference.destroy_network()
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
