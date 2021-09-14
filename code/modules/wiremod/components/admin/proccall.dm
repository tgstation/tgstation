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
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	var/datum/port/input/option/proccall_options

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

/obj/item/circuit_component/proccall/populate_ports()
	entity = add_input_port("Target", PORT_TYPE_ATOM)
	proc_name = add_input_port("Proc Name", PORT_TYPE_STRING)
	arguments = add_input_port("Arguments", PORT_TYPE_LIST)

	output_value = add_output_port("Output Value", PORT_TYPE_ANY)

/obj/item/circuit_component/proccall/input_received(datum/port/input/port)

	var/called_on
	if(proccall_options.value == COMP_PROC_OBJECT)
		called_on = entity.value
	else
		called_on = GLOBAL_PROC

	if(!called_on)
		return

	var/to_invoke = proc_name.value
	var/params = arguments.value || list()

	if(!to_invoke)
		return

	GLOB.AdminProcCaller = "CHAT_[parent.display_name]" //_ won't show up in ckeys so it'll never match with a real admin
	var/result = WrapAdminProcCall(called_on, to_invoke, params)
	GLOB.AdminProcCaller = null

	output_value.set_output(result)

#undef COMP_PROC_GLOBAL
#undef COMP_PROC_OBJECT
