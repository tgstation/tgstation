/**
 * # Router Component
 *
 * Writes one of multiple inputs to one of multiple outputs.
 */
/obj/item/circuit_component/router
	display_name = "Router"
	desc = "Copies the input chosen by \"Input Selector\" to the output chosen by \"Output Selector\"."
	category = "Utility"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/input/option/router_options

	/// Which ports to connect.
	var/datum/port/input/input_selector
	var/datum/port/input/output_selector

	/// How many ports to have.
	var/input_port_amount = 4
	var/output_port_amount = 4

	/// Current type of the ports
	var/current_type

	/// The ports to route.
	var/list/datum/port/input/ins
	var/list/datum/port/output/outs

/obj/item/circuit_component/router/populate_options()
	router_options = add_option_port("Router Options", GLOB.wiremod_basic_types)

/obj/item/circuit_component/router/populate_ports()
	current_type = router_options.value
	if(input_port_amount > 1)
		input_selector = add_input_port("Input Selector", PORT_TYPE_NUMBER, default = 1)
	if(output_port_amount > 1)
		output_selector = add_input_port("Output Selector", PORT_TYPE_NUMBER, default = 1)
	ins = list()
	for(var/port_id in 1 to input_port_amount)
		ins += add_input_port(input_port_amount > 1 ? "Input [port_id]" : "Input", current_type)
	outs = list()
	for(var/port_id in 1 to output_port_amount)
		outs += add_output_port(output_port_amount > 1 ? "Output [port_id]" : "Output", current_type)

/obj/item/circuit_component/router/Destroy()
	input_selector = null
	output_selector = null
	ins.Cut()
	ins = null
	outs.Cut()
	outs = null
	return ..()


// If I is in range, L[I]. If I is out of range, wrap around.
#define WRAPACCESS(L, I) L[(((I||1)-1)%length(L)+length(L))%length(L)+1]
/obj/item/circuit_component/router/pre_input_received(datum/port/input/port)
	var/current_option = router_options.value
	if(current_type != current_option)
		current_type = current_option
		for(var/datum/port/input/input as anything in ins)
			input.set_datatype(current_type)
		for(var/datum/port/output/output as anything in outs)
			output.set_datatype(current_type)

/obj/item/circuit_component/router/input_received(datum/port/input/port)
	var/datum/port/input/input = WRAPACCESS(ins, input_selector ? input_selector.value : 1)
	var/datum/port/output/output = WRAPACCESS(outs, output_selector ? output_selector.value : 1)
	output.set_output(input.value)

/obj/item/circuit_component/router/multiplexer
	display_name = "Multiplexer"
	desc = "Copies the input chosen by \"Input Selector\" to the output."
	output_port_amount = 1
