/obj/item/integrated_circuit/transfer
	category_text = "Data Transfer"
	power_draw_per_use = 2

/obj/item/integrated_circuit/transfer/multiplexer
	name = "two multiplexer"
	desc = "This is what those in the business tend to refer to as a 'mux', or data selector. It moves data from one of the selected inputs to the output."
	extended_desc = "The first input pin is used to select which of the other input pins which has its data moved to the output. \
	If the input selection is outside the valid range then no output is given."
	complexity = 2
	icon_state = "mux2"
	inputs = list("input selection" = IC_PINTYPE_NUMBER)
	outputs = list("output" = IC_PINTYPE_ANY)
	activators = list("select" = IC_PINTYPE_PULSE_IN, "on select" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 4
	var/number_of_pins = 2

/obj/item/integrated_circuit/transfer/multiplexer/Initialize()
	for(var/i = 1 to number_of_pins)
		inputs["input [i]"] = IC_PINTYPE_ANY // This is just a string since pins don't get built until ..() is called.

	complexity = number_of_pins
	. = ..()
	desc += " It has [number_of_pins] input pins."
	extended_desc += " This multiplexer has a range from 1 to [inputs.len - 1]."

/obj/item/integrated_circuit/transfer/multiplexer/do_work()
	var/input_index = get_pin_data(IC_INPUT, 1)

	if(!isnull(input_index) && (input_index >= 1 && input_index < inputs.len))
		set_pin_data(IC_OUTPUT, 1,get_pin_data(IC_INPUT, input_index + 1))
		push_data()
	activate_pin(2)

/obj/item/integrated_circuit/transfer/multiplexer/medium
	name = "four multiplexer"
	icon_state = "mux4"
	number_of_pins = 4

/obj/item/integrated_circuit/transfer/multiplexer/large
	name = "eight multiplexer"
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "mux8"
	number_of_pins = 8

/obj/item/integrated_circuit/transfer/multiplexer/huge
	name = "sixteen multiplexer"
	icon_state = "mux16"
	w_class = WEIGHT_CLASS_SMALL
	number_of_pins = 16

/obj/item/integrated_circuit/transfer/demultiplexer
	name = "two demultiplexer"
	desc = "This is what those in the business tend to refer to as a 'demux'. It moves data from the input to one of the selected outputs."
	extended_desc = "The first input pin is used to select which of the output pins is given the data from the second input pin. \
	If the output selection is outside the valid range then no output is given."
	complexity = 2
	icon_state = "dmux2"
	inputs = list("output selection" = IC_PINTYPE_NUMBER, "input" = IC_PINTYPE_ANY)
	outputs = list()
	activators = list("select" = IC_PINTYPE_PULSE_IN, "on select" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 4
	var/number_of_pins = 2

/obj/item/integrated_circuit/transfer/demultiplexer/Initialize()
	for(var/i = 1 to number_of_pins)
		outputs["output [i]"] = IC_PINTYPE_ANY
	complexity = number_of_pins

	. = ..()
	desc += " It has [number_of_pins] output pins."
	extended_desc += " This demultiplexer has a range from 1 to [outputs.len]."

/obj/item/integrated_circuit/transfer/demultiplexer/do_work()
	var/output_index = get_pin_data(IC_INPUT, 1)
	if(!isnull(output_index) && (output_index >= 1 && output_index <= outputs.len))
		var/datum/integrated_io/O = outputs[output_index]
		O.data = get_pin_data(IC_INPUT, 2)
		O.push_data()

	activate_pin(2)

/obj/item/integrated_circuit/transfer/demultiplexer/medium
	name = "four demultiplexer"
	icon_state = "dmux4"
	number_of_pins = 4

/obj/item/integrated_circuit/transfer/demultiplexer/large
	name = "eight demultiplexer"
	icon_state = "dmux8"
	w_class = WEIGHT_CLASS_SMALL
	number_of_pins = 8

/obj/item/integrated_circuit/transfer/demultiplexer/huge
	name = "sixteen demultiplexer"
	icon_state = "dmux16"
	w_class = WEIGHT_CLASS_SMALL
	number_of_pins = 16

/obj/item/integrated_circuit/transfer/pulsedemultiplexer
	name = "two pulse demultiplexer"
	desc = "Selector switch to choose the pin to be activated by number."
	extended_desc = "The first input pin is used to select which of the pulse out pins will be activated after activation of the circuit. \
	If the output selection is outside the valid range then no output is given."
	complexity = 2
	icon_state = "dmux2"
	inputs = list("output selection" = IC_PINTYPE_NUMBER)
	outputs = list()
	activators = list("select" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 4
	var/number_of_pins = 2

/obj/item/integrated_circuit/transfer/pulsedemultiplexer/Initialize()
	for(var/i = 1 to number_of_pins)
		activators["output [i]"] = IC_PINTYPE_PULSE_OUT
	complexity = number_of_pins

	. = ..()
	desc += " It has [number_of_pins] output pins."
	extended_desc += " This pulse demultiplexer has a range from 1 to [activators.len - 1]."

/obj/item/integrated_circuit/transfer/pulsedemultiplexer/do_work()
	var/output_index = get_pin_data(IC_INPUT, 1)

	if(output_index == CLAMP(output_index, 1, number_of_pins))
		activate_pin(round(output_index + 1 ,1))

/obj/item/integrated_circuit/transfer/pulsedemultiplexer/medium
	name = "four pulse demultiplexer"
	icon_state = "dmux4"
	number_of_pins = 4

/obj/item/integrated_circuit/transfer/pulsedemultiplexer/large
	name = "eight pulse demultiplexer"
	icon_state = "dmux8"
	w_class = WEIGHT_CLASS_SMALL
	number_of_pins = 8

/obj/item/integrated_circuit/transfer/pulsedemultiplexer/huge
	name = "sixteen pulse demultiplexer"
	icon_state = "dmux16"
	w_class = WEIGHT_CLASS_SMALL
	number_of_pins = 16

/obj/item/integrated_circuit/transfer/pulsemultiplexer
	name = "two pulse multiplexer"
	desc = "Pulse in pins to choose the pin value to be sent."
	extended_desc = "The input pulses are used to select which of the input pins has its data moved to the output."
	complexity = 2
	icon_state = "dmux2"
	inputs = list()
	outputs = list("output" = IC_PINTYPE_ANY)
	activators = list("on selected" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 4
	var/number_of_pins = 2

/obj/item/integrated_circuit/transfer/pulsemultiplexer/Initialize()
	for(var/i = 1 to number_of_pins)
		inputs["input [i]"] = IC_PINTYPE_ANY
	for(var/i = 1 to number_of_pins)
		activators["input [i]"] = IC_PINTYPE_PULSE_IN
	complexity = number_of_pins

	. = ..()
	desc += " It has [number_of_pins] pulse in pins and [number_of_pins] output pins."
	extended_desc += " This pulse multiplexer has a range from 1 to [activators.len - 1]."

/obj/item/integrated_circuit/transfer/pulsemultiplexer/do_work(ord)
	var/input_index = ord - 2

	if(!isnull(input_index) && (input_index >= 0 && input_index < inputs.len))
		set_pin_data(IC_OUTPUT, 1,get_pin_data(IC_INPUT, input_index + 1))
		push_data()
	activate_pin(1)

/obj/item/integrated_circuit/transfer/pulsemultiplexer/medium
	name = "four pulse multiplexer"
	icon_state = "dmux4"
	number_of_pins = 4

/obj/item/integrated_circuit/transfer/pulsemultiplexer/large
	name = "eight pulse multiplexer"
	icon_state = "dmux8"
	w_class = WEIGHT_CLASS_SMALL
	number_of_pins = 8

/obj/item/integrated_circuit/transfer/pulsemultiplexer/huge
	name = "sixteen pulse multiplexer"
	icon_state = "dmux16"
	w_class = WEIGHT_CLASS_SMALL
	number_of_pins = 16

/obj/item/integrated_circuit/transfer/wire_node
	name = "wire node"
	desc = "Just a wire node to make wiring easier. Transfers the pulse from in to out."
	icon_state = "wire_node"
	activators = list("pulse in" = IC_PINTYPE_PULSE_IN, "pulse out" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 0
	complexity = 0
	size = 0.1

/obj/item/integrated_circuit/transfer/wire_node/do_work()
	activate_pin(2)
