/**
 * # Variable Component
 *
 * Abstract component for handling variables
 */
/obj/item/circuit_component/variable
	display_name = "Abstract Variable Component"
	desc = "You shouldn't be seeing this."

	/// Variable name
	var/datum/port/input/option/variable_name

	var/datum/circuit_variable/current_variable
	circuit_size = 0

/obj/item/circuit_component/variable/populate_options()
	variable_name = add_option_port("Variable", null)

/obj/item/circuit_component/variable/add_to(obj/item/integrated_circuit/added_to)
	. = ..()
	variable_name.possible_options = added_to.circuit_variables

/obj/item/circuit_component/variable/removed_from(obj/item/integrated_circuit/removed_from)
	variable_name.possible_options = null
	return ..()

/obj/item/circuit_component/variable/pre_input_received(datum/port/input/port)
	if(!parent)
		return

	var/variable_string = variable_name.value
	if(!variable_string)
		remove_current_variable()
		return

	var/datum/circuit_variable/variable = parent.circuit_variables[variable_string]
	if(!variable)
		remove_current_variable()
		return

	set_current_variable(variable)

/obj/item/circuit_component/variable/proc/remove_current_variable()
	SIGNAL_HANDLER
	if(current_variable)
		current_variable.remove_listener(src)
		UnregisterSignal(current_variable, COMSIG_PARENT_QDELETING)
		current_variable = null

/obj/item/circuit_component/variable/proc/set_current_variable(datum/circuit_variable/variable)
	if(variable == current_variable)
		return

	remove_current_variable()
	current_variable = variable
	current_variable.add_listener(src)
	RegisterSignal(current_variable, COMSIG_PARENT_QDELETING, .proc/remove_current_variable)
