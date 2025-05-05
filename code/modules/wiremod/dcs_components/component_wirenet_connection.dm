/datum/component/circuit_component_wirenet_connection
	var/cable_layer = CABLE_LAYER_2

	var/atom/movable/tracked_shell

	var/atom/movable/tracked_movable
	var/obj/structure/cable/tracked_node
	var/datum/powernet/tracked_powernet

	var/static/list/turf_connections = list(COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON = PROC_REF(on_atom_initialized_on_turf))

	/// What action sets the component to link to cable layer 1
	var/layer_1_action

	/// What action sets the component to link to cable layer 2
	var/layer_2_action

	/// What action sets the component to link to cable layer 3
	var/layer_3_action

	/// Callback to invoke when the component is connected to a powernet
	var/datum/callback/connection_callback

	/// Callback to invoke when the component is disconnected from a powernet
	var/datum/callback/disconnection_callback

	/// Callback to invoke after setting the cable layer to link to
	var/datum/callback/post_set_cable_layer_callback

/datum/component/circuit_component_wirenet_connection/Initialize(layer_1_action = CABLE_LAYER_1_NAME, layer_2_action = CABLE_LAYER_2_NAME, layer_3_action = CABLE_LAYER_3_NAME, datum/callback/connection_callback, datum/callback/disconnection_callback, datum/callback/post_set_cable_layer_callback)
	. = ..()
	if(!istype(parent, /obj/item/circuit_component))
		return COMPONENT_INCOMPATIBLE
	src.layer_1_action = layer_1_action
	src.layer_2_action = layer_2_action
	src.layer_3_action = layer_3_action
	src.connection_callback = connection_callback
	src.disconnection_callback = disconnection_callback
	src.post_set_cable_layer_callback = post_set_cable_layer_callback

/datum/component/circuit_component_wirenet_connection/Destroy(force)
	. = ..()
	connection_callback = null
	disconnection_callback = null
	post_set_cable_layer_callback = null

/datum/component/circuit_component_wirenet_connection/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CIRCUIT_COMPONENT_PERFORM_ACTION, PROC_REF(on_action))
	RegisterSignal(parent, COMSIG_CIRCUIT_COMPONENT_ADDED, PROC_REF(on_parent_added_to_circuit))
	RegisterSignal(parent, COMSIG_CIRCUIT_COMPONENT_REMOVED, PROC_REF(on_parent_removed_from_circuit))

/datum/component/circuit_component_wirenet_connection/UnregisterFromParent()
	unset_shell()
	UnregisterSignal(parent, list(COMSIG_CIRCUIT_COMPONENT_PERFORM_ACTION, COMSIG_CIRCUIT_COMPONENT_ADDED, COMSIG_CIRCUIT_COMPONENT_REMOVED))

/datum/component/circuit_component_wirenet_connection/proc/on_parent_added_to_circuit(_source, obj/item/integrated_circuit/circuit)
	SIGNAL_HANDLER
	RegisterSignal(circuit, COMSIG_CIRCUIT_SET_SHELL, PROC_REF(on_circuit_set_shell))
	RegisterSignal(circuit, COMSIG_CIRCUIT_SHELL_REMOVED, PROC_REF(unset_shell))
	if(circuit.shell)
		set_shell(circuit.shell)

/datum/component/circuit_component_wirenet_connection/proc/on_parent_removed_from_circuit(_source, obj/item/integrated_circuit/circuit)
	SIGNAL_HANDLER
	unset_shell()
	UnregisterSignal(circuit, list(COMSIG_CIRCUIT_SET_SHELL, COMSIG_CIRCUIT_SHELL_REMOVED))

/datum/component/circuit_component_wirenet_connection/proc/on_circuit_set_shell(_source, atom/movable/shell)
	SIGNAL_HANDLER
	set_shell(shell)

/datum/component/circuit_component_wirenet_connection/proc/set_shell(atom/movable/new_shell)
	tracked_shell = new_shell
	if(isassembly(new_shell))
		RegisterSignals(new_shell, list(COMSIG_ASSEMBLY_ATTACHED, COMSIG_ASSEMBLY_ADDED_TO_BUTTON), PROC_REF(on_assembly_shell_attached))
		RegisterSignals(new_shell, list(COMSIG_ASSEMBLY_DETACHED, COMSIG_ASSEMBLY_REMOVED_FROM_BUTTON), PROC_REF(on_assembly_shell_detached))
	else
		set_tracked_movable(new_shell)

/datum/component/circuit_component_wirenet_connection/proc/unset_shell()
	SIGNAL_HANDLER
	unset_tracked_movable()
	if(!tracked_shell)
		return
	if(isassembly(tracked_shell))
		UnregisterSignal(tracked_shell, list(COMSIG_ASSEMBLY_ATTACHED, COMSIG_ASSEMBLY_DETACHED, COMSIG_ASSEMBLY_ADDED_TO_BUTTON, COMSIG_ASSEMBLY_REMOVED_FROM_BUTTON))
	tracked_shell = null

/datum/component/circuit_component_wirenet_connection/proc/on_assembly_shell_attached(_source, atom/holder)
	SIGNAL_HANDLER
	if(ismovable(holder))
		set_tracked_movable(holder)

/datum/component/circuit_component_wirenet_connection/proc/on_assembly_shell_detached()
	SIGNAL_HANDLER
	unset_tracked_movable()

/datum/component/circuit_component_wirenet_connection/proc/set_tracked_movable(atom/movable/new_tracked_movable)
	if(tracked_movable == new_tracked_movable) //Should only happen when an assembly holder the assembly was attached to calls on_attach when it itself is attached to something
		return
	tracked_movable = new_tracked_movable
	RegisterSignal(new_tracked_movable, COMSIG_MOVABLE_SET_ANCHORED, PROC_REF(on_tracked_movable_set_anchored))
	RegisterSignal(new_tracked_movable, COMSIG_QDELETING, PROC_REF(unset_tracked_movable))
	if(tracked_movable.anchored)
		try_set_tracked_node()

/datum/component/circuit_component_wirenet_connection/proc/unset_tracked_movable()
	SIGNAL_HANDLER
	unset_tracked_node()
	if(!tracked_movable)
		return
	UnregisterSignal(tracked_movable, list(COMSIG_MOVABLE_SET_ANCHORED, COMSIG_QDELETING))
	tracked_movable = null

/datum/component/circuit_component_wirenet_connection/proc/on_tracked_movable_set_anchored(atom/movable/source, now_anchored)
	SIGNAL_HANDLER
	if(now_anchored)
		try_set_tracked_node()
	else
		unset_tracked_node()

/datum/component/circuit_component_wirenet_connection/proc/try_set_tracked_node()
	SIGNAL_HANDLER
	if(tracked_node)
		unset_tracked_node()
	var/turf/our_turf = get_turf(tracked_movable)
	var/obj/structure/cable/node = our_turf.get_cable_node(cable_layer)
	if(!node)
		AddElement(/datum/element/connect_loc, turf_connections)
		return
	set_tracked_node(node)

/datum/component/circuit_component_wirenet_connection/proc/on_atom_initialized_on_turf(_source, obj/structure/cable/initialized)
	SIGNAL_HANDLER
	if(!istype(initialized))
		return
	if(!(initialized.cable_layer & cable_layer))
		return
	set_tracked_node(initialized)

/datum/component/circuit_component_wirenet_connection/proc/set_tracked_node(obj/structure/cable/node)
	tracked_node = node
	RemoveElement(/datum/element/connect_loc, turf_connections)
	RegisterSignal(tracked_movable, COMSIG_MOVABLE_MOVED, PROC_REF(unset_tracked_node)) //Because of wack cases of something pushing an anchored object
	RegisterSignal(node, COMSIG_CABLE_ADDED_TO_POWERNET, PROC_REF(set_tracked_powernet))
	RegisterSignal(node, COMSIG_CABLE_REMOVED_FROM_POWERNET, PROC_REF(unset_tracked_powernet))
	RegisterSignal(node, COMSIG_QDELETING, PROC_REF(unset_tracked_node))
	if(node.powernet)
		set_tracked_powernet(node.powernet)

/datum/component/circuit_component_wirenet_connection/proc/unset_tracked_node()
	SIGNAL_HANDLER
	unset_tracked_powernet()
	if(!tracked_node)
		return
	UnregisterSignal(tracked_movable, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(tracked_node, list(COMSIG_CABLE_ADDED_TO_POWERNET, COMSIG_CABLE_REMOVED_FROM_POWERNET, COMSIG_QDELETING))
	tracked_node = null

/datum/component/circuit_component_wirenet_connection/proc/set_tracked_powernet(datum/powernet/source)
	SIGNAL_HANDLER
	tracked_powernet = source
	connection_callback?.Invoke(source)

/datum/component/circuit_component_wirenet_connection/proc/unset_tracked_powernet()
	SIGNAL_HANDLER
	if(!tracked_powernet)
		return
	disconnection_callback?.Invoke(tracked_powernet)
	tracked_powernet = null

/datum/component/circuit_component_wirenet_connection/proc/on_action(obj/item/circuit_component/component, mob/user, action)
	SIGNAL_HANDLER
	switch(action)
		if(CABLE_LAYER_1_NAME)
			set_cable_layer(CABLE_LAYER_1)
		if(CABLE_LAYER_2_NAME)
			set_cable_layer(CABLE_LAYER_2)
		if(CABLE_LAYER_3_NAME)
			set_cable_layer(CABLE_LAYER_3)

/datum/component/circuit_component_wirenet_connection/proc/set_cable_layer(new_layer)
	if(cable_layer == new_layer)
		return
	cable_layer = new_layer
	post_set_cable_layer_callback?.Invoke(new_layer)
	if(tracked_movable?.anchored)
		try_set_tracked_node()
