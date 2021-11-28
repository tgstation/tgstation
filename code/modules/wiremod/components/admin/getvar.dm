/**
 * # Get Variable Component
 *
 * A component that gets a variable on an object
 */
/obj/item/circuit_component/get_variable
	display_name = "Get Variable"
	desc = "A component that gets a variable on an object."
	category = "Admin"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	/// Whether to grab a global variable or a variable from this entity.
	var/datum/port/input/option/getvar_options

	/// Entity to get variable of
	var/datum/port/input/entity

	/// Expected type of output
	var/datum/port/input/option/expected_output_type

	/// Variable name
	var/datum/port/input/variable_name

	/// Variable value
	var/datum/port/output/output_value

/obj/item/circuit_component/get_variable/populate_options()
	getvar_options = add_option_port("Variable Options", list("Object", "Global"))
	expected_output_type = add_option_port("Expected Output Type", GLOB.wiremod_fundamental_types)

/obj/item/circuit_component/get_variable/populate_ports()
	entity = add_input_port("Target", PORT_TYPE_DATUM)
	variable_name = add_input_port("Variable Name", PORT_TYPE_STRING, order = 2)
	output_value = add_output_port("Output Value", PORT_TYPE_ANY, order = 2)

/obj/item/circuit_component/get_variable/pre_input_received(datum/port/input/port)
	if(port == getvar_options)
		remove_input_port(entity)
		entity = null
		if(getvar_options.value == "Object")
			entity = add_input_port("Target", PORT_TYPE_DATUM)

	if(port == expected_output_type)
		if(output_value.datatype != expected_output_type.value)
			output_value.set_datatype(expected_output_type.value)

/obj/item/circuit_component/get_variable/input_received(datum/port/input/port)
	var/atom/object = entity?.value
	if(getvar_options.value == "Global")
		object = GLOB

	var/var_name = variable_name.value
	if(!var_name || !object)
		output_value.set_output(null)
		return

	if(!object.can_vv_get(var_name) || !(var_name in object.vars))
		output_value.set_output(null)
		return

	output_value.set_output(object.vars[var_name])
