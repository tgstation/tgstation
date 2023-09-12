///To be used when there is the need of an atmos connection without repathing everything (eg: cryo.dm)
/obj/machinery/atmospherics/components/unary/machine_connector
	name = "machine connector"
	desc = "Internal connector to interface with the pipes."

	can_unwrench = FALSE

	use_power = NO_POWER_USE
	layer = GAS_FILTER_LAYER
	hide = TRUE
	shift_underlay_only = FALSE

	pipe_flags = PIPING_ONE_PER_TURF

	///Reference to the machine we are connected to
	var/obj/machinery/connected_machine

/obj/machinery/atmospherics/components/unary/machine_connector/Initialize(mapload, connecting_machine, direction)
	dir = direction
	. = ..()
	connected_machine = connecting_machine
	SSair.start_processing_machine(connected_machine)
	register_with_machine()

/**
 * Register various signals that are required for the proper work of the connector
 */
/obj/machinery/atmospherics/components/unary/machine_connector/proc/register_with_machine()
	RegisterSignal(connected_machine, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(pre_move_connected_machine))
	RegisterSignal(connected_machine, COMSIG_MOVABLE_MOVED, PROC_REF(moved_connected_machine))
	RegisterSignal(connected_machine, COMSIG_MACHINERY_DEFAULT_ROTATE_WRENCH, PROC_REF(wrenched_connected_machine))
	RegisterSignal(connected_machine, COMSIG_OBJ_DECONSTRUCT, PROC_REF(deconstruct_connected_machine))

/**
 * Unregister the signals previously registered
 */
/obj/machinery/atmospherics/components/unary/machine_connector/proc/unregister_from_machine()
	UnregisterSignal(connected_machine, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOVABLE_PRE_MOVE,
		COMSIG_MACHINERY_DEFAULT_ROTATE_WRENCH,
		COMSIG_OBJ_DECONSTRUCT,
	))

/**
 * Called when the machine has been moved, reconnect to the pipe network
 */
/obj/machinery/atmospherics/components/unary/machine_connector/proc/moved_connected_machine()
	SIGNAL_HANDLER
	forceMove(get_turf(connected_machine))
	reconnect_connector()

/**
 * Called before the machine moves, disconnect from the pipe network
 */
/obj/machinery/atmospherics/components/unary/machine_connector/proc/pre_move_connected_machine()
	SIGNAL_HANDLER
	disconnect_connector()

/**
 * Called when the machine has been rotated, resets the connection to the pipe network with the new direction
 */
/obj/machinery/atmospherics/components/unary/machine_connector/proc/wrenched_connected_machine()
	SIGNAL_HANDLER
	disconnect_connector()
	reconnect_connector()

/**
 * Called when the machine has been deconstructed
 */
/obj/machinery/atmospherics/components/unary/machine_connector/proc/deconstruct_connected_machine()
	SIGNAL_HANDLER
	disconnect_connector()
	SSair.stop_processing_machine(connected_machine)
	unregister_from_machine()
	connected_machine = null
	qdel(src)

/**
 * Handles the disconnection from the pipe network
 */
/obj/machinery/atmospherics/components/unary/machine_connector/proc/disconnect_connector()
	var/obj/machinery/atmospherics/node = nodes[1]
	if(node)
		if(src in node.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node.disconnect(src)
		nodes[1] = null
	if(parents[1])
		nullify_pipenet(parents[1])

/**
 * Handles the reconnection to the pipe network
 */
/obj/machinery/atmospherics/components/unary/machine_connector/proc/reconnect_connector()
	dir = connected_machine.dir
	set_init_directions()
	var/obj/machinery/atmospherics/node = nodes[1]
	atmos_init()
	node = nodes[1]
	if(node)
		node.atmos_init()
		node.add_member(src)
	SSair.add_to_rebuild_queue(src)
