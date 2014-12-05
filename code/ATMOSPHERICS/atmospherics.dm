/*
Quick overview:

Pipes combine to form pipelines
Pipelines and other atmospheric objects combine to form pipe_networks
	Note: A single pipe_network represents a completely open space

Pipes -> Pipelines
Pipelines + Other Objects -> Pipe network

*/

#define PIPE_TYPE_STANDARD 0
#define PIPE_TYPE_HE       1

/obj/machinery/atmospherics
	anchored = 1
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = ENVIRON
	var/nodealert = 0

	// Which directions can we connect with?
	var/initialize_directions = 0

	var/obj/machinery/atmospherics/mirror //not actually an object reference, but a type. The reflection of the current pipe

	// Pipe painter color setting.
	var/_color

	var/list/available_colors

// Find a connecting /obj/machinery/atmospherics in specified direction.
/obj/machinery/atmospherics/proc/findConnecting(var/direction)
	for(var/obj/machinery/atmospherics/target in get_step(src,direction))
		if(target.initialize_directions & get_dir(target,src))
			return target

// Ditto, but for heat-exchanging pipes.
/obj/machinery/atmospherics/proc/findConnectingHE(var/direction)
	for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,direction))
		if(target.initialize_directions_he & get_dir(target,src))
			return target

/obj/machinery/atmospherics/proc/getNodeType(var/node_id)
	return PIPE_TYPE_STANDARD

// A bit more flexible.
// @param connect_dirs integer Directions at which we should check for connections.
/obj/machinery/atmospherics/proc/findAllConnections(var/connect_dirs)
	var/node_id=0
	for(var/direction in cardinal)
		if(connect_dirs & direction)
			node_id++
			var/obj/machinery/atmospherics/found
			var/node_type=getNodeType(node_id)
			switch(node_type)
				if(PIPE_TYPE_STANDARD)
					found = findConnecting(direction)
				if(PIPE_TYPE_HE)
					found = findConnectingHE(direction)
				else
					error("UNKNOWN RESPONSE FROM [src.type]/getNodeType([node_id]): [node_type]")
					return
			if(!found) continue
			var/node_var="node[node_id]"
			if(!(node_var in vars))
				testing("[node_var] not in vars.")
				return
			if(!vars[node_var])
				vars[node_var] = found

// Wait..  What the fuck?
// I asked /tg/ and bay and they have no idea why this is here, so into the trash it goes. - N3X
// Re-enabled for debugging.
/obj/machinery/atmospherics/process()
	build_network()

/obj/machinery/atmospherics/proc/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	// Check to see if should be added to network. Add self if so and adjust variables appropriately.
	// Note don't forget to have neighbors look as well!

	return null

/obj/machinery/atmospherics/proc/build_network()
	// Called to build a network from this node
	return null

/obj/machinery/atmospherics/proc/return_network(obj/machinery/atmospherics/reference)
	// Returns pipe_network associated with connection to reference
	// Notes: should create network if necessary
	// Should never return null

	return null

/obj/machinery/atmospherics/proc/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	// Used when two pipe_networks are combining

/obj/machinery/atmospherics/proc/return_network_air(datum/network/reference)
	// Return a list of gas_mixture(s) in the object
	//		associated with reference pipe_network for use in rebuilding the networks gases list
	// Is permitted to return null

/obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)

/obj/machinery/atmospherics/update_icon()
	return null

/obj/machinery/atmospherics/proc/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	error("[src] does not define a buildFrom!")
	return FALSE