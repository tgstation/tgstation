/**
 * # Set Variable Component
 *
 * A component that sets a variable on an object
 */
/obj/item/circuit_component/set_variable
	display_name = "Set Variable"
	desc = "A component that sets a variable on an object."
	category = "Admin"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	/// Whether to resolve weakrefs or not
	var/datum/port/input/resolve_weakrefs

	/// Entity to set variable of
	var/datum/port/input/entity

	/// Variable name
	var/datum/port/input/variable_name

	/// New value to set the variable name to.
	var/datum/port/input/new_value


/obj/item/circuit_component/set_variable/populate_ports()
	resolve_weakrefs = add_input_port("Resolve Weakrefs", PORT_TYPE_NUMBER, default = TRUE)
	entity = add_input_port("Target", PORT_TYPE_DATUM)
	variable_name = add_input_port("Variable Name", PORT_TYPE_STRING)
	new_value = add_input_port("New Value", PORT_TYPE_ANY)

/obj/item/circuit_component/set_variable/input_received(datum/port/input/port)
	var/atom/object = entity.value
	var/var_name = variable_name.value
	if(!var_name || !object)
		return

	var/resolved_new_value = new_value.value
	if(islist(resolved_new_value) && resolve_weakrefs.value)
		var/list/to_resolve = resolved_new_value
		resolved_new_value = recursive_list_resolve(to_resolve)

	object.vv_edit_var(var_name, resolved_new_value)
