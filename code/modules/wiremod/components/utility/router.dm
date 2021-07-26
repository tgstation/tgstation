/**
 * # Router Component
 *
 * Writes one of multiple inputs to one of multiple outputs.
 */
/obj/item/circuit_component/router
	display_name = "Router"
	display_desc = "Writes an input of your choice to an output of your choice. If you set 'Which Input?' to any of ...-6,-2,2,6,10,... and 'Which Output?' to any of ...-5,-1,3,7,11,..., Input 2 will be written to Output 3."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// Which ports to connect.
	var/datum/port/input/which_input
	var/datum/port/input/which_output

	/// How many ports to have.
	var/input_port_amount = 4
	var/output_port_amount = 4

	/// Current type of the ports
	var/current_type

	/// The ports to route.
	var/list/datum/port/input/ins
	var/list/datum/port/output/outs

/obj/item/circuit_component/router/populate_options()
	var/static/component_options = list(
		PORT_TYPE_ANY,
		PORT_TYPE_STRING,
		PORT_TYPE_NUMBER,
		PORT_TYPE_LIST,
		PORT_TYPE_ATOM,
	)
	options = component_options

/obj/item/circuit_component/router/Initialize()
	. = ..()
	current_type = current_option
	if(input_port_amount > 1)
		which_input = add_input_port("'Which Input?'", PORT_TYPE_NUMBER, default = 1)
	if(output_port_amount > 1)
		which_output = add_input_port("'Which Output?'", PORT_TYPE_NUMBER, default = 1)
	ins = list()
	for(var/port_id in 1 to input_port_amount)
		ins += add_input_port(input_port_amount > 1 ? "Input [port_id]" : "Input", current_type)
	outs = list()
	for(var/port_id in 1 to output_port_amount)
		outs += add_output_port(output_port_amount > 1 ? "Output [port_id]" : "Output", current_type)

/obj/item/circuit_component/router/Destroy()
	ins.Cut()
	ins = null
	outs.Cut()
	outs = null
	return ..()


// If I is in range, L[I]. If I is out of range, wrap around.
#define WRAPACCESS(L, I) L[(((I||1)-1)%length(L)+length(L))%length(L)+1]
/obj/item/circuit_component/router/input_received(datum/port/input/port)
	. = ..()
	if(current_type != current_option)
		current_type = current_option
		for(var/datum/port/input/input as anything in ins)
			input.set_datatype(current_type)
		for(var/datum/port/output/output as anything in outs)
			output.set_datatype(current_type)
	if(.)
		return
	var/datum/port/input/input = WRAPACCESS(ins, which_input ? which_input.input_value : 1)
	var/datum/port/output/output = WRAPACCESS(outs, which_output ? which_output.input_value : 1)
	output.set_output(input.input_value)

/obj/item/circuit_component/router/multiplexer
	display_name = "Multiplexer"
	display_desc = "Writes an input of your choice to the output. If you set 'Which Input?' to any of ...-5,-1,3,7,11,..., Input 2 will be written to the output."
	output_port_amount = 1
