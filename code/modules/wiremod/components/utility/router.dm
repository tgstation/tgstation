/**
 * # Router Component
 *
 * Writes one of multiple inputs to one of multiple outputs.
 */
/obj/item/circuit_component/router
	display_name = "Router"
	display_desc = "Don't know how to wire up your circuit? This lets the circuit decide.\n\nThe input indicated by the Input input will be written to the output indicated by the Output input. Got it? Indices out of range will wrap around."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// Which ports to connect.
	var/datum/port/input/nin
	var/datum/port/input/nout

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
	nin = add_input_port("Input", PORT_TYPE_NUMBER, default = 1)
	nout = add_input_port("Output", PORT_TYPE_NUMBER, default = 1)
	ins = list()
	for(var/port_id in 1 to input_port_amount)
		ins += add_input_port("Input [port_id]", current_type)
	outs = list()
	for(var/port_id in 1 to output_port_amount)
		outs += add_output_port("Output [port_id]", current_type)

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
	var/datum/port/input/input = WRAPACCESS(ins, nin.input_value)
	var/datum/port/output/output = WRAPACCESS(outs, nout.input_value)
	output.set_output(input.input_value)

