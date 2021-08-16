/**
 * Called on destroy(mostly deconstruction) and when moving nodes around, disconnect the nodes from the network
 * Arguments:
 * * i - is the current iteration of the node, based on the device_type (from 1 to 4)
 */
/obj/machinery/atmospherics/proc/nullifyNode(i)
	if(nodes[i])
		var/obj/machinery/atmospherics/N = nodes[i]
		N.disconnect(src)
		nodes[i] = null

/**
 * Getter for node_connects
 *
 * Return a list of the nodes that can connect to other machines, get called by atmosinit()
 */
/obj/machinery/atmospherics/proc/getNodeConnects()
	var/list/node_connects = list()
	node_connects.len = device_type

	var/init_directions = GetInitDirections()
	for(var/i in 1 to device_type)
		for(var/direction in GLOB.cardinals)
			if(!(direction & init_directions))
				continue
			if(direction in node_connects)
				continue
			node_connects[i] = direction
			break

	return node_connects

/**
 * Setter for device direction
 *
 * Set the direction to either SOUTH or WEST if the pipe_flag is set to PIPING_CARDINAL_AUTONORMALIZE, called in New(), used mostly by layer manifolds
 */
/obj/machinery/atmospherics/proc/normalize_cardinal_directions()
	switch(dir)
		if(SOUTH)
			setDir(NORTH)
		if(WEST)
			setDir(EAST)

/**
 * setter for pipe layers
 *
 * Set the layer of the pipe that the device has to a new_layer
 * Arguments:
 * * new_layer - the layer at which we want the piping_layer to be (1 to 5)
 */
/obj/machinery/atmospherics/proc/setPipingLayer(new_layer)
	piping_layer = (pipe_flags & PIPING_DEFAULT_LAYER_ONLY) ? PIPING_LAYER_DEFAULT : new_layer
	update_appearance()

/**
 * Check if a node can actually exists by connecting to another machine
 * called on atmosinit()
 * Arguments:
 * * obj/machinery/atmospherics/target - the machine we are connecting to
 * * iteration - the current node we are checking (from 1 to 4)
 */
/obj/machinery/atmospherics/proc/can_be_node(obj/machinery/atmospherics/target, iteration)
	return connection_check(target, piping_layer)

/**
 * Find a connecting /obj/machinery/atmospherics in specified direction, called by relaymove()
 * used by ventcrawling mobs to check if they can move inside a pipe in a specific direction
 * Arguments:
 * * direction - the direction we are checking against
 * * prompted_layer - the piping_layer we are inside
 */
/obj/machinery/atmospherics/proc/findConnecting(direction, prompted_layer)
	for(var/obj/machinery/atmospherics/target in get_step_multiz(src, direction))
		if(!(target.initialize_directions & get_dir(target,src)) && !istype(target, /obj/machinery/atmospherics/pipe/multiz))
			continue
		if(connection_check(target, prompted_layer))
			return target

/**
 * Check the connection between two nodes
 *
 * Check if our machine and the target machine are connectable by both calling isConnectable and by checking that the directions and piping_layer are compatible
 * called by can_be_node() (for building a network) and findConnecting() (for ventcrawling)
 * Arguments:
 * * obj/machinery/atmospherics/target - the machinery we want to connect to
 * * given_layer - the piping_layer we are checking
 */
/obj/machinery/atmospherics/proc/connection_check(obj/machinery/atmospherics/target, given_layer)
	if(isConnectable(target, given_layer) && target.isConnectable(src, given_layer) && check_init_directions(target))
		return TRUE
	return FALSE

/**
 * check if the initialized direction are the same on both sides (or if is a multiz adapter)
 * returns TRUE or FALSE if the connection is possible or not
 * Arguments:
 * * obj/machinery/atmospherics/target - the machinery we want to connect to
 */
/obj/machinery/atmospherics/proc/check_init_directions(obj/machinery/atmospherics/target)
	if((initialize_directions & get_dir(src, target) && target.initialize_directions & get_dir(target,src)) || istype(target, /obj/machinery/atmospherics/pipe/multiz))
		return TRUE
	return FALSE

/**
 * check if the piping layer and color are the same on both sides (grey can connect to all colors)
 * returns TRUE or FALSE if the connection is possible or not
 * Arguments:
 * * obj/machinery/atmospherics/target - the machinery we want to connect to
 * * given_layer - the piping_layer we are connecting to
 */
/obj/machinery/atmospherics/proc/isConnectable(obj/machinery/atmospherics/target, given_layer)
	if(isnull(given_layer))
		given_layer = piping_layer
	if(check_connectable_layer(target, given_layer) && target.loc != loc && check_connectable_color(target))
		return TRUE
	return FALSE

/**
 * check if the piping layer are the same on both sides or one of them has the PIPING_ALL_LAYER flag
 * returns TRUE if one of the parameters is TRUE
 * called by isConnectable()
 * Arguments:
 * * obj/machinery/atmospherics/target - the machinery we want to connect to
 * * given_layer - the piping_layer we are connecting to
 */
/obj/machinery/atmospherics/proc/check_connectable_layer(obj/machinery/atmospherics/target, given_layer)
	if(target.piping_layer == given_layer || target.pipe_flags & PIPING_ALL_LAYER)
		return TRUE
	return FALSE

/**
 * check if the color are the same on both sides or if one of the pipes are grey or have the PIPING_ALL_COLORS flag
 * returns TRUE if one of the parameters is TRUE
 * Arguments:
 * * obj/machinery/atmospherics/target - the machinery we want to connect to
 */
/obj/machinery/atmospherics/proc/check_connectable_color(obj/machinery/atmospherics/target)
	if(lowertext(target.pipe_color) == lowertext(pipe_color) || ((target.pipe_flags | pipe_flags) & PIPING_ALL_COLORS) || lowertext(target.pipe_color) == lowertext(COLOR_VERY_LIGHT_GRAY) || lowertext(pipe_color) == lowertext(COLOR_VERY_LIGHT_GRAY))
		return TRUE
	return FALSE

/**
 * Set the initial directions of the device (NORTH || SOUTH || EAST || WEST), called on New()
 */
/obj/machinery/atmospherics/proc/SetInitDirections(init_dir)
	return

/**
 * Getter of initial directions
 */
/obj/machinery/atmospherics/proc/GetInitDirections()
	return initialize_directions

/**
 * Disconnects the nodes
 *
 * Called by nullifyNode(), it disconnects two nodes by removing the reference id from the node itself that called this proc
 * Arguments:
 * * obj/machinery/atmospherics/reference - the machinery we are removing from the node connection
 */
/obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)
	if(istype(reference, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = reference
		P.destroy_network()
	nodes[nodes.Find(reference)] = null
	update_appearance()
