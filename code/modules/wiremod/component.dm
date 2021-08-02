/**
 * # Integrated Circuit Component
 *
 * A component that performs a function when given an input
 *
 * Can be attached to an integrated circuitboard, where it can then
 * be connected between other components to provide an output or to receive
 * an input. This is the base type of all components
 */
/obj/item/circuit_component
	name = COMPONENT_DEFAULT_NAME
	icon = 'icons/obj/module.dmi'
	icon_state = "component"
	inhand_icon_state = "electronic"

	/// The name of the component shown on the UI
	var/display_name = "Generic"

	/// The integrated_circuit that this component is attached to.
	var/obj/item/integrated_circuit/parent

	/// A list that contains the outpurt ports on this component
	/// Used to connect between the ports
	var/list/datum/port/output/output_ports = list()

	/// A list that contains the components the input ports on this component
	/// Used to connect between the ports
	var/list/datum/port/input/input_ports = list()

	/// Generic trigger input for triggering this component
	var/datum/port/input/trigger_input
	var/datum/port/output/trigger_output

	/// The flags of the circuit to control basic generalised behaviour.
	var/circuit_flags = NONE

	/// Used to determine the x position of the component within the UI
	var/rel_x = 0
	/// Used to determine the y position of the component within the UI
	var/rel_y = 0

	/// The power usage whenever this component receives an input
	var/power_usage_per_input = 1

	/// The current selected option
	var/current_option
	/// The options that this component can take on. Limited to strings
	var/list/options

	// Whether the component is removable or not. Only affects user UI
	var/removable = TRUE

	// Defines which shells can accept this component. If set to null then all shells can use it.
	var/required_shells = null

/obj/item/circuit_component/Initialize()
	. = ..()
	if(name == COMPONENT_DEFAULT_NAME)
		name = "[lowertext(display_name)] [COMPONENT_DEFAULT_NAME]"
	populate_options()
	if(length(options))
		current_option = options[1]

	return INITIALIZE_HINT_LATELOAD

/// Called when the options variable should be set.
/obj/item/circuit_component/proc/populate_options()
	return

/obj/item/circuit_component/LateInitialize()
	. = ..()
	if(circuit_flags & CIRCUIT_FLAG_INPUT_SIGNAL)
		trigger_input = add_input_port("Trigger", PORT_TYPE_SIGNAL)
	if(circuit_flags & CIRCUIT_FLAG_OUTPUT_SIGNAL)
		trigger_output = add_output_port("Triggered", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/Destroy()
	if(parent)
		// Prevents a Destroy() recursion
		var/obj/item/integrated_circuit/old_parent = parent
		parent = null
		old_parent.remove_component(src)

	trigger_input = null
	trigger_output = null

	QDEL_LIST(output_ports)
	QDEL_LIST(input_ports)
	return ..()

/**
 * Called when a shell is registered from the component/the component is added to a circuit.
 *
 * Register all signals here on the shell.
 * Arguments:
 * * shell - Shell being registered
 */
/obj/item/circuit_component/proc/register_shell(atom/movable/shell)
	return

/**
 * Called when a shell is unregistered from the component/the component is removed from a circuit.
 *
 * Unregister all signals here on the shell.
 * Arguments:
 * * shell - Shell being unregistered
 */
/obj/item/circuit_component/proc/unregister_shell(atom/movable/shell)
	return

/**
 * Disconnects a component from other components
 *
 * Disconnects both the input and output ports of the component
 */
/obj/item/circuit_component/proc/disconnect()
	for(var/datum/port/output/port_to_disconnect as anything in output_ports)
		port_to_disconnect.disconnect()

	for(var/datum/port/input/port_to_disconnect as anything in input_ports)
		port_to_disconnect.disconnect()

/**
 * Sets the option on this component
 *
 * Can only be a value from the options variable
 * Arguments:
 * * option - The option that has been switched to.
 */
/obj/item/circuit_component/proc/set_option(option)
	current_option = option
	TRIGGER_CIRCUIT_COMPONENT(src, null)

/**
 * Adds an input port and returns it
 *
 * Arguments:
 * * name - The name of the input port
 * * type - The datatype it handles
 * * trigger - Whether this input port triggers an update on the component when updated.
 */
/obj/item/circuit_component/proc/add_input_port(name, type, trigger = TRUE, default = null, index = null)
	var/datum/port/input/input_port = new(src, name, type, trigger, default)
	if(index)
		input_ports.Insert(index, input_port)
	else
		input_ports += input_port
	if(parent)
		SStgui.update_uis(parent)
	return input_port

/**
 * Removes an input port and deletes it. This will not cleanup any references made by derivatives of the circuit component
 *
 * Arguments:
 * * input_port - The input port to remove.
 */
/obj/item/circuit_component/proc/remove_input_port(datum/port/input/input_port)
	input_ports -= input_port
	qdel(input_port)
	if(parent)
		SStgui.update_uis(parent)

/**
 * Adds an output port and returns it
 *
 * Arguments:
 * * name - The name of the output port
 * * type - The datatype it handles.
 */
/obj/item/circuit_component/proc/add_output_port(name, type)
	var/datum/port/output/output_port = new(src, name, type)
	output_ports += output_port
	return output_port

/**
 * Removes an output port and deletes it. This will not cleanup any references made by derivatives of the circuit component
 *
 * Arguments:
 * * output_port - The output port to remove.
 */
/obj/item/circuit_component/proc/remove_output_port(datum/port/output/output_port)
	output_ports -= output_port
	qdel(output_port)
	if(parent)
		SStgui.update_uis(parent)

/**
 * Called whenever an input is received from one of the ports.
 *
 * Return value indicates that the circuit should not do anything. Also prevents an output signal.
 * Arguments:
 * * port - Can be null. The port that sent the input
 */
/obj/item/circuit_component/proc/input_received(datum/port/input/port)
	SHOULD_CALL_PARENT(TRUE)
	if(!parent?.on)
		return TRUE

	if(!parent.admin_only)
		if(circuit_flags & CIRCUIT_FLAG_ADMIN)
			message_admins("[display_name] tried to execute on [parent.get_creator_admin()] that has set the admin_only variable to TRUE!")
			return TRUE

		var/obj/item/stock_parts/cell/cell = parent.get_cell()
		if(!cell?.use(power_usage_per_input))
			return TRUE

	if((circuit_flags & CIRCUIT_FLAG_INPUT_SIGNAL) && !COMPONENT_TRIGGERED_BY(trigger_input, port))
		return TRUE

/// Called when this component is about to be added to an integrated_circuit.
/obj/item/circuit_component/proc/add_to(obj/item/integrated_circuit/added_to)
	if(required_shells && LAZYLEN(required_shells))
		for(var/shell_type in required_shells)
			if(istype(added_to, shell_type) || istype(added_to.loc, shell_type))
				return TRUE
		return FALSE
	return TRUE

/// Called when this component is removed from an integrated_circuit.
/obj/item/circuit_component/proc/removed_from(obj/item/integrated_circuit/removed_from)
	return

/**
 * Gets the UI notices to be displayed on the CircuitInfo panel.
 *
 * Returns a list of buttons in the following format
 * list(
 *   "icon" = ICON(string)
 *   "content" = CONTENT(string)
 *   "color" = COLOR(string, not a hex)
 * )
 */
/obj/item/circuit_component/proc/get_ui_notices()
	. = list()

	if(!removable)
		. += create_ui_notice("Unremovable", "red", "lock")


	if(length(input_ports))
		. += create_ui_notice("Power Usage Per Input: [power_usage_per_input]", "orange", "bolt")

/**
 * Creates a UI notice entry to be used in get_ui_notices()
 *
 * Returns a list that can then be added to the return list in get_ui_notices()
 */
/obj/item/circuit_component/proc/create_ui_notice(content, color, icon)
	SHOULD_BE_PURE(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)
	return list(list(
		"icon" = icon,
		"content" = content,
		"color" = color,
	))

/**
 * Creates a table UI notice entry to be used in get_ui_notices()
 *
 * Returns a list that can then be added to the return list in get_ui_notices()
 * Used by components to list their available columns. Recommended to use at the end of get_ui_notices()
 */
/obj/item/circuit_component/proc/create_table_notices(list/entries)
	SHOULD_BE_PURE(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)
	. = list()
	. += create_ui_notice("Available Columns:", "grey", "question-circle")


	for(var/entry in entries)
		. += create_ui_notice("Column Name: '[entry]'", "grey", "columns")

/obj/item/circuit_component/proc/register_usb_parent(atom/movable/parent)
	return

/obj/item/circuit_component/proc/unregister_usb_parent(atom/movable/parent)
	return
