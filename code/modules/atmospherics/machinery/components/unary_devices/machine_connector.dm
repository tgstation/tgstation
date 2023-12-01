///To be used when there is the need of an atmos connection without repathing everything (eg: cryo.dm)
/datum/gas_machine_connector

	var/obj/machinery/connected_machine
	var/obj/machinery/atmospherics/components/unary/gas_connector

/datum/gas_machine_connector/New(location, obj/machinery/connecting_machine = null, direction = SOUTH, gas_volume)
	gas_connector = new(location)

	connected_machine = connecting_machine
	if(!connected_machine)
		QDEL_NULL(gas_connector)
		qdel(src)
		return

	gas_connector.dir = connected_machine.dir
	gas_connector.airs[1].volume = gas_volume

	SSair.start_processing_machine(connected_machine)
	register_with_machine()
	gas_connector.set_init_directions()
	gas_connector.atmos_init()
	SSair.add_to_rebuild_queue(gas_connector)

/datum/gas_machine_connector/Destroy()
	connected_machine = null
	QDEL_NULL(gas_connector)
	return ..()

/**
 * Register various signals that are required for the proper work of the connector
 */
/datum/gas_machine_connector/proc/register_with_machine()
	RegisterSignal(connected_machine, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(pre_move_connected_machine))
	RegisterSignal(connected_machine, COMSIG_MOVABLE_MOVED, PROC_REF(moved_connected_machine))
	RegisterSignal(connected_machine, COMSIG_MACHINERY_DEFAULT_ROTATE_WRENCH, PROC_REF(wrenched_connected_machine))
	RegisterSignal(connected_machine, COMSIG_QDELETING, PROC_REF(deconstruct_connected_machine))

/**
 * Unregister the signals previously registered
 */
/datum/gas_machine_connector/proc/unregister_from_machine()
	UnregisterSignal(connected_machine, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOVABLE_PRE_MOVE,
		COMSIG_MACHINERY_DEFAULT_ROTATE_WRENCH,
		COMSIG_QDELETING,
	))

/**
 * Called when the machine has been moved, reconnect to the pipe network
 */
/datum/gas_machine_connector/proc/moved_connected_machine()
	SIGNAL_HANDLER
	gas_connector.forceMove(get_turf(connected_machine))
	reconnect_connector()

/**
 * Called before the machine moves, disconnect from the pipe network
 */
/datum/gas_machine_connector/proc/pre_move_connected_machine()
	SIGNAL_HANDLER
	disconnect_connector()

/**
 * Called when the machine has been rotated, resets the connection to the pipe network with the new direction
 */
/datum/gas_machine_connector/proc/wrenched_connected_machine()
	SIGNAL_HANDLER
	disconnect_connector()
	reconnect_connector()

/**
 * Called when the machine has been deconstructed
 */
/datum/gas_machine_connector/proc/deconstruct_connected_machine()
	SIGNAL_HANDLER
	disconnect_connector()
	SSair.stop_processing_machine(connected_machine)
	unregister_from_machine()
	connected_machine = null
	QDEL_NULL(gas_connector)
	qdel(src)

/**
 * Handles the disconnection from the pipe network
 */
/datum/gas_machine_connector/proc/disconnect_connector()
	var/obj/machinery/atmospherics/node = gas_connector.nodes[1]
	if(node)
		if(gas_connector in node.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node.disconnect(gas_connector)
		gas_connector.nodes[1] = null
	if(gas_connector.parents[1])
		gas_connector.nullify_pipenet(gas_connector.parents[1])

/**
 * Handles the reconnection to the pipe network
 */
/datum/gas_machine_connector/proc/reconnect_connector()
	gas_connector.dir = connected_machine.dir
	gas_connector.set_init_directions()
	var/obj/machinery/atmospherics/node = gas_connector.nodes[1]
	gas_connector.atmos_init()
	node = gas_connector.nodes[1]
	if(node)
		node.atmos_init()
		node.add_member(gas_connector)
	SSair.add_to_rebuild_queue(gas_connector)
