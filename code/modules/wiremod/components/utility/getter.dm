/**
 * # Getter Component
 *
 * Gets the current value from a variable.
 */
/obj/item/circuit_component/getter
	display_name = "Variable Getter"
	desc = "A component that gets a variable globally on the circuit."

	/// Variable name
	var/datum/port/input/option/variable_name

	/// The value of the variable
	var/datum/port/output/value

	var/datum/circuit_variable/current_variable

/obj/item/circuit_component/getter/populate_options()
	variable_name = add_option_port("Variable", null)

/obj/item/circuit_component/getter/add_to(obj/item/integrated_circuit/added_to)
	. = ..()
	variable_name.possible_options = added_to.circuit_variables

/obj/item/circuit_component/getter/removed_from(obj/item/integrated_circuit/removed_from)
	variable_name.possible_options = null
	return ..()

/obj/item/circuit_component/getter/populate_ports()
	value = add_output_port("Value", PORT_TYPE_ANY)

/obj/item/circuit_component/getter/pre_input_received(datum/port/input/port)
	if(!parent)
		return

	var/variable_string = variable_name.value
	if(!variable_string)
		remove_current_variable()
		value.set_output(null)
		return

	var/datum/circuit_variable/variable = parent.circuit_variables[variable_string]
	if(!variable)
		remove_current_variable()
		value.set_output(null)
		return

	set_current_variable(variable)
	value.set_output(variable.value)

/obj/item/circuit_component/getter/proc/remove_current_variable()
	SIGNAL_HANDLER
	if(current_variable)
		current_variable.remove_listener(src)
		UnregisterSignal(current_variable, COMSIG_PARENT_QDELETING)
		current_variable = null

/obj/item/circuit_component/getter/proc/set_current_variable(datum/circuit_variable/variable)
	if(variable == current_variable)
		return

	remove_current_variable()
	current_variable = variable
	current_variable.add_listener(src)
	RegisterSignal(current_variable, COMSIG_PARENT_QDELETING, .proc/remove_current_variable)
	value.set_datatype(variable.datatype)
