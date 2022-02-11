#define COMP_PROC_GLOBAL "Global"
#define COMP_PROC_OBJECT "Object"


/**
 * # Proc Call Component
 *
 * A component that calls a proc on an object and outputs the return value
 */
/obj/item/circuit_component/proccall
	display_name = "Proc Call"
	desc = "A component that calls a proc on an object."
	category = "Admin"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	var/datum/port/input/option/proccall_options

	/// Expected type of output
	var/datum/port/input/option/expected_output_type

	/// Entity to proccall on
	var/datum/port/input/entity

	/// Proc to call
	var/datum/port/input/proc_name

	/// Arguments
	var/datum/port/input/arguments

	/// Returns the output from the proccall
	var/datum/port/output/output_value

/obj/item/circuit_component/proccall/populate_options()
	var/static/list/component_options = list(
		COMP_PROC_OBJECT,
		COMP_PROC_GLOBAL,
	)

	proccall_options = add_option_port("Proccall Options", component_options)

	expected_output_type = add_option_port("Expected Output Type", GLOB.wiremod_fundamental_types)

/obj/item/circuit_component/proccall/populate_ports()
	entity = add_input_port("Target", PORT_TYPE_DATUM)
	proc_name = add_input_port("Proc Name", PORT_TYPE_STRING)
	arguments = add_input_port("Arguments", PORT_TYPE_LIST(PORT_TYPE_ANY))

	output_value = add_output_port("Output Value", PORT_TYPE_ANY)

/obj/item/circuit_component/proccall/pre_input_received(datum/port/input/port)
	if(port == expected_output_type)
		if(output_value.datatype != expected_output_type.value)
			output_value.set_datatype(expected_output_type.value)

/obj/item/circuit_component/proccall/input_received(datum/port/input/port)
	var/called_on
	if(proccall_options.value == COMP_PROC_OBJECT)
		called_on = entity.value
	else
		called_on = GLOBAL_PROC

	if(!called_on)
		return

	var/to_invoke = proc_name.value
	var/list/params = arguments.value || list()

	if(!to_invoke)
		return

	if(called_on != GLOBAL_PROC && !hascall(called_on, to_invoke))
		return

	var/list/resolved_params = recursive_list_resolve(params)
	log_admin_circuit("[parent.get_creator()] proccalled '[to_invoke]' on [called_on] with params \[[resolved_params.Join(", ")]].")
	INVOKE_ASYNC(src, .proc/do_proccall, called_on, to_invoke, resolved_params)

/obj/item/circuit_component/proccall/proc/do_proccall(called_on, to_invoke, params)
	var/result = HandleUserlessProcCall(parent.get_creator(), called_on, to_invoke, params)
	output_value.set_output(result)

#undef COMP_PROC_GLOBAL
#undef COMP_PROC_OBJECT
