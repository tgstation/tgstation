/datum/component/gas_connector
	//Reference to the spawned pipe
	var/obj/machinery/atmospherics/components/unary/internal_connector

/datum/component/gas_connector/Initialize(obj/parent_obj, internal_volume)
	. = ..()
	internal_connector = new /obj/machinery/atmospherics/components/unary(parent_obj.loc)
	internal_connector.dir = parent_obj.dir
	internal_connector.airs[1].volume = internal_volume
	internal_connector.atmos_init()
	SSair.start_processing_machine(parent_obj)

/datum/component/gas_connector/Destroy(force, silent)
	var/datum/gas_mixture/air = internal_connector.airs[1]
	var/turf/parent_turf = get_turf(parent)
	parent_turf.assume_air(air)

	QDEL_NULL(internal_connector)

	var/obj/parent_obj = parent
	SSair.stop_processing_machine(parent_obj)

	return..()

/datum/component/gas_connector/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(pre_move_parent))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(moved_parent))
	RegisterSignal(parent, COMSIG_MACHINERY_DEFAULT_ROTATE_WRENCH, PROC_REF(wrenched_parent))

/datum/component/gas_connector/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOVABLE_PRE_MOVE,
		COMSIG_MACHINERY_DEFAULT_ROTATE_WRENCH,
	))

/datum/component/gas_connector/proc/moved_parent()
	SIGNAL_HANDLER
	internal_connector.forceMove(get_turf(parent))
	reconnect_connector()

/datum/component/gas_connector/proc/pre_move_parent()
	SIGNAL_HANDLER
	disconnect_connector()

/datum/component/gas_connector/proc/wrenched_parent()
	SIGNAL_HANDLER
	disconnect_connector()
	reconnect_connector()

/datum/component/gas_connector/proc/disconnect_connector()
	var/obj/machinery/atmospherics/node = internal_connector.nodes[1]
	if(node)
		if(internal_connector in node.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node.disconnect(internal_connector)
		internal_connector.nodes[1] = null
	if(internal_connector.parents[1])
		internal_connector.nullify_pipenet(internal_connector.parents[1])

/datum/component/gas_connector/proc/reconnect_connector()
	var/obj/parent_obj = parent
	internal_connector.dir = parent_obj.dir
	internal_connector.set_init_directions()
	var/obj/machinery/atmospherics/node = internal_connector.nodes[1]
	internal_connector.atmos_init()
	node = internal_connector.nodes[1]
	if(node)
		node.atmos_init()
		node.add_member(internal_connector)
	SSair.add_to_rebuild_queue(internal_connector)
