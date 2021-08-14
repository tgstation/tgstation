/**
 * # Get Variable Component
 *
 * A component that gets a variable on an object
 */
/obj/item/circuit_component/get_variable
	display_name = "Get Variable"
	desc = "A component that gets a variable on an object."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	/// Entity to get variable of
	var/datum/port/input/entity

	/// Variable name
	var/datum/port/input/variable_name

	/// Variable value
	var/datum/port/output/output_value


/obj/item/circuit_component/get_variable/Initialize()
	. = ..()
	entity = add_input_port("Target", PORT_TYPE_ATOM)
	variable_name = add_input_port("Variable Name", PORT_TYPE_STRING)

	output_value = add_output_port("Output Value", PORT_TYPE_ANY)

/obj/item/circuit_component/get_variable/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return
	var/atom/object = entity.input_value
	var/var_name = variable_name.input_value
	if(!var_name || !object)
		output_value.set_output(null)
		return

	if(!object.can_vv_get(var_name) || !(var_name in object.vars))
		output_value.set_output(null)
		return

	output_value.set_output(object.vars[var_name])
