/obj/machinery/atmospherics/pipe/layer_manifold
	name = "pipe-layer manifold"
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifoldlayer"
	desc = "A special pipe to bridge pipe layers with."
	dir = SOUTH
	initialize_directions = NORTH|SOUTH
	volume = 260 //6 averaged pipe segments
	pipe_flags = ALL_LAYER
	var/list/layer_nodes = list()
	var/obj/machinery/atmospherics/other_node = null
	piping_layer = PIPING_LAYER_DEFAULT

/obj/machinery/atmospherics/pipe/layer_manifold/SetInitDirections()
	switch(dir)
		if(NORTH || SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST || WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/layer_manifold/New()
	for(var/pipelayer = PIPING_LAYER_MIN; pipelayer <= PIPING_LAYER_MAX; pipelayer += 1)
		layer_nodes.Add(null)
	..()

/obj/machinery/atmospherics/pipe/layer_manifold/setPipingLayer(new_layer = PIPING_LAYER_DEFAULT)
	piping_layer = PIPING_LAYER_DEFAULT

/obj/machinery/atmospherics/pipe/layer_manifold/on_construction()
	findAllConnections(dir)
	for(var/obj/machinery/atmospherics/node in layer_nodes)
		node.Initialize()
		node.atmosinit()
		node.build_network()
	if (other_node)
		other_node.Initialize()
		other_node.atmosinit()
		other_node.build_network()
	. = ..()

/obj/machinery/atmospherics/pipe/layer_manifold/pipeline_expansion()
	return layer_nodes + other_node

/obj/machinery/atmospherics/pipe/layer_manifold/Destroy()
	for(var/obj/machinery/atmospherics/node in layer_nodes)
		node.disconnect(src)
	if(other_node)
		other_node.disconnect(src)
	..()

/obj/machinery/atmospherics/pipe/layer_manifold/disconnect(obj/machinery/atmospherics/reference)
	if(reference != other_node)
		for(var/pipelayer = PIPING_LAYER_MIN; pipelayer <= PIPING_LAYER_MAX; pipelayer += 1)
			if(reference == layer_nodes[pipelayer])
				if(istype(layer_nodes[pipelayer], /obj/machinery/atmospherics/pipe))
					var/obj/machinery/atmospherics/pipe/PL = layer_nodes[pipelayer]
					qdel(PL.parent)
				layer_nodes[pipelayer] = null
	else
		other_node = null
	..()

/obj/machinery/atmospherics/pipe/layer_manifold/update_icon()
	/*overlays.len = 0
	alpha = invisibility ? 128 : 255
	icon_state = initial(icon_state)
	if(other_node)
		var/icon/con = new/icon(icon,"manifoldl_other_con")
		overlays += new/image(con, dir = turn(src.dir, 180)) //adds the back connector
	for(var/pipelayer = PIPING_LAYER_MIN; pipelayer <= PIPING_LAYER_MAX; pipelayer += 1)
		if(layer_nodes[pipelayer]) //we are connected at this layer
			var/layer_diff = pipelayer - PIPING_LAYER_DEFAULT
			var/image/con = image(icon(icon,"manifoldl_con",dir))
			con.pixel_x = layer_diff * PIPING_LAYER_P_X
			con.pixel_y = layer_diff * PIPING_LAYER_P_Y
			overlays += con*/
	..()

/obj/machinery/atmospherics/pipe/layer_manifold/Initialize(mapload)
	findAllConnections(initialize_directions)
	update_icon()
	..()

/obj/machinery/atmospherics/pipe/layer_manifold/proc/findAllConnections(d)
	for(var/iter = PIPING_LAYER_MIN; iter <= PIPING_LAYER_MAX; iter += 1)
		var/obj/machinery/atmospherics/found
		found = findConnecting(d, iter)
		if(!found)
			continue
		layer_nodes[iter] = found
	var/obj/machinery/atmospherics/found2 = findConnecting(turn(d, 180), PIPING_LAYER_DEFAULT)
	if(found2)
		other_node = found2

/obj/machinery/atmospherics/pipe/layer_manifold/isConnectable(obj/machinery/atmospherics/target, direction, given_layer)
	if(direction == turn(src.dir, 180))
		return (given_layer == PIPING_LAYER_DEFAULT)
	. = ..()

/obj/machinery/atmospherics/pipe/layer_manifold/relaymove(mob/living/user, dir)
	if(initialize_directions & dir)
		return ..()
	if((NORTH|EAST) & dir)
		user.ventcrawl_layer = Clamp(user.ventcrawl_layer + 1, PIPING_LAYER_MIN, PIPING_LAYER_MAX)
	if((SOUTH|WEST) & dir)
		user.ventcrawl_layer = Clamp(user.ventcrawl_layer - 1, PIPING_LAYER_MIN, PIPING_LAYER_MAX)
	user << "You align yourself with the [user.ventcrawl_layer]\th output."

		/*
/obj/machinery/atmospherics/pipe/layer_adapter
	name = "pipe-layer adapter"

	icon = 'icons/obj/atmospherics/pipe_adapter.dmi'
	icon_state = "adapter_1"
	baseicon = "adapter"

	color = PIPE_COLOR_GREY

	dir = SOUTH
	initialize_directions = NORTH|SOUTH

	volume = 260 //6 averaged pipe segments

	pipe_flags = ALL_LAYER

	var/obj/machinery/atmospherics/layer_node = null
	var/obj/machinery/atmospherics/mid_node = null

/obj/machinery/atmospherics/pipe/layer_adapter/New()
	..()
	switch(dir)
		if(NORTH,SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST,WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/layer_adapter/setPipingLayer(var/new_layer = PIPING_LAYER_DEFAULT)
	piping_layer = new_layer

/obj/machinery/atmospherics/pipe/layer_adapter/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = pipe.get_pipe_dir()
	var/turf/T = loc
	level = T.intact ? LEVEL_ABOVE_FLOOR : LEVEL_BELOW_FLOOR
	update_planes_and_layers()
	initialize(1)
	if(!mid_node && !layer_node)
		to_chat(usr, "<span class='warning'>There's nothing to connect this adapter to! A pipe segment must be connected to at least one other object!</span>")
		return 0
	update_icon()
	build_network()
	if (mid_node)
		mid_node.initialize()
		mid_node.build_network()
	if (layer_node)
		layer_node.initialize()
		layer_node.build_network()
	return 1

/obj/machinery/atmospherics/pipe/layer_adapter/hide(var/i)
	update_icon()

/obj/machinery/atmospherics/pipe/layer_adapter/pipeline_expansion()
	return list(layer_node, mid_node)


/obj/machinery/atmospherics/pipe/layer_adapter/process()
	if(!parent)
		. = ..()
	atmos_machines.Remove(src)

/obj/machinery/atmospherics/pipe/layer_adapter/Destroy()
	if(mid_node)
		mid_node.disconnect(src)
	if(layer_node)
		layer_node.disconnect(src)
	..()


/obj/machinery/atmospherics/pipe/layer_adapter/disconnect(var/obj/machinery/atmospherics/reference)
	if(reference == mid_node)
		if(istype(mid_node, /obj/machinery/atmospherics/pipe) && !isnull(parent))
			returnToPool(parent)
		mid_node = null
	if(reference == layer_node)
		if(istype(layer_node, /obj/machinery/atmospherics/pipe) && !isnull(parent))
			returnToPool(parent)
		layer_node = null

	..()

/obj/machinery/atmospherics/pipe/layer_adapter/update_icon()
	overlays.len = 0
	alpha = invisibility ? 128 : 255
	icon_state = "[baseicon]_[piping_layer]"
	if(layer_node)
		var/layer_diff = piping_layer - PIPING_LAYER_DEFAULT

		var/image/con = image(icon(src.icon,"layer_con",turn(src.dir,180)))
		con.pixel_x = layer_diff * PIPING_LAYER_P_X
		con.pixel_y = layer_diff * PIPING_LAYER_P_Y

		overlays += con
	if(!mid_node && !layer_node)
		qdel(src)

	if (exposed() || (mid_node && mid_node.exposed()) || (layer_node && layer_node.exposed()))
		invisibility = 0
	else
		invisibility = 101

/obj/machinery/atmospherics/pipe/layer_adapter/initialize(var/skip_update_icon=0)

	findAllConnections(initialize_directions)

	var/turf/T = src.loc			// hide if turf is not intact
	hide(T.intact)
	if(!skip_update_icon)
		update_icon()

	T.soft_add_holomap(src)

/obj/machinery/atmospherics/pipe/layer_adapter/findAllConnections(var/connect_dirs)
	for(var/direction in cardinal)
		if(connect_dirs & direction)
			if(direction == dir) //we're facing this
				var/obj/machinery/atmospherics/found
				var/node_type=getNodeType(direction)
				switch(node_type)
					if(PIPE_TYPE_STANDARD)
						found = findConnecting(direction, PIPING_LAYER_DEFAULT)
					if(PIPE_TYPE_HE)
						found = findConnectingHE(direction, PIPING_LAYER_DEFAULT)
					else
						error("UNKNOWN RESPONSE FROM [src.type]/getNodeType([direction]): [node_type]")
				if(!found)
					continue
				mid_node = found
			else
				var/obj/machinery/atmospherics/found
				var/node_type=getNodeType(direction)
				switch(node_type)
					if(PIPE_TYPE_STANDARD)
						found = findConnecting(direction, piping_layer) //we pass the layer to find the pipe
					if(PIPE_TYPE_HE)
						found = findConnectingHE(direction, piping_layer)
					else
						error("UNKNOWN RESPONSE FROM [src.type]/getNodeType([piping_layer]): [node_type]")
						return
				if(!found)
					continue
				layer_node = found

/obj/machinery/atmospherics/pipe/layer_adapter/isConnectable(var/obj/machinery/atmospherics/target, var/direction, var/given_layer)
	if(direction == dir)
		return (given_layer == PIPING_LAYER_DEFAULT)
	return ..()

/obj/machinery/atmospherics/pipe/layer_adapter/getNodeType()
	return PIPE_TYPE_STANDARD

//We would normally set layer here, but I don't want to
/obj/machinery/atmospherics/pipe/layer_adapter/Entered()
	return

/obj/machinery/atmospherics/pipe/layer_adapter/relaymove(mob/living/user, direction)
	// Autoset layer
	if(direction & initialize_directions)
		user.ventcrawl_layer = (direction == dir) ? PIPING_LAYER_DEFAULT : piping_layer
		to_chat(user, "You are redirected into the [user.ventcrawl_layer]\th piping layer.")
		return ..()*/