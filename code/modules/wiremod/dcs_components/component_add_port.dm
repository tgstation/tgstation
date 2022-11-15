/// Helper component that handles users adding/removing ports from a circuit component.
/datum/component/circuit_component_add_port
	dupe_mode = COMPONENT_DUPE_ALLOWED

	/// The list to add the ports to when created
	var/list/datum/port/port_list
	/// The action to add a port on
	var/add_action
	/// The action to remove a port on
	var/remove_action
	/// The type of port
	var/port_type = PORT_TYPE_ANY
	/// Whether we are adding output ports or not
	var/is_output = FALSE
	/// The prefix of the new ports
	var/prefix = "Port"
	/// The order of the new ports
	var/order = 1
	/// The minimum amount of ports required
	var/minimum_amount = 1
	/// The maximum amount of ports allowed
	var/maximum_amount = 10

/datum/component/circuit_component_add_port/Initialize(list/port_list, add_action, remove_action, port_type, is_output = FALSE, prefix = "Port", order = 1, minimum_amount = 1, maximum_amount = 10)
	. = ..()
	if(!istype(parent, /obj/item/circuit_component))
		return COMPONENT_INCOMPATIBLE
	src.port_list = port_list
	src.add_action = add_action
	src.remove_action = remove_action
	src.port_type = port_type
	src.is_output = is_output
	src.prefix = prefix
	src.order = order
	src.minimum_amount = minimum_amount
	src.maximum_amount = maximum_amount

	if(minimum_amount > 0)
		for(var/i in 1 to minimum_amount)
			port_list += add_port()

/datum/component/circuit_component_add_port/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CIRCUIT_COMPONENT_PERFORM_ACTION, PROC_REF(on_action))
	RegisterSignal(parent, COMSIG_CIRCUIT_COMPONENT_SAVE_DATA, PROC_REF(on_data_saved))
	RegisterSignal(parent, COMSIG_CIRCUIT_COMPONENT_LOAD_DATA, PROC_REF(on_data_loaded))

/datum/component/circuit_component_add_port/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_CIRCUIT_COMPONENT_PERFORM_ACTION,
		COMSIG_CIRCUIT_COMPONENT_SAVE_DATA,
		COMSIG_CIRCUIT_COMPONENT_LOAD_DATA,
	))

/datum/component/circuit_component_add_port/proc/on_action(obj/item/circuit_component/component, mob/user, action)
	SIGNAL_HANDLER
	if(length(port_list))
		/// Take the port type of the first stored list element, useful if the types of the ports change
		port_type = port_list[1].datatype

	if(action == add_action)
		if(length(port_list) >= maximum_amount)
			return
		port_list += add_port()
	else if(action == remove_action)
		if(length(port_list) <= minimum_amount)
			return
		if(is_output)
			component.remove_output_port(pop(port_list))
		else
			component.remove_input_port(pop(port_list))

/datum/component/circuit_component_add_port/proc/add_port()
	var/obj/item/circuit_component/component = parent
	var/list/arguments = list("[prefix] [length(port_list) + 1]", port_type, order = src.order + (length(port_list) + 1) * 0.001)
	if(is_output)
		return component.add_output_port(arglist(arguments))
	else
		return component.add_input_port(arglist(arguments))

/datum/component/circuit_component_add_port/proc/on_data_saved(datum/source, list/data)
	SIGNAL_HANDLER
	data["port_count"] = length(port_list)

/datum/component/circuit_component_add_port/proc/on_data_loaded(datum/source, list/data)
	SIGNAL_HANDLER
	var/count = data["port_count"]

	if(!count || count <= length(port_list))
		return

	while(length(port_list) < count)
		port_list += add_port()
