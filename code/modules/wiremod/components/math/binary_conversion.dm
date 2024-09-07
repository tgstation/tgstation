/**
 * # Binary Conversion Component
 *
 * Return an array of binary digits from a number input.
 */
/obj/item/circuit_component/binary_conversion
	display_name = "Binary Conversion"
	desc = "Splits a decimal number into an array of binary digits, or bits, represented as 1 or 0 and often used in boolean or binary operations like AND, OR and XOR."
	category = "Math"

	/// One number
	var/datum/port/input/number

	/// Many binary digits
	var/list/datum/port/bit_array = list()

	ui_buttons = list(
		"plus" = "add",
		"minus" = "remove"
	)


/obj/item/circuit_component/binary_conversion/populate_ports()
	AddComponent(/datum/component/circuit_component_add_port, \
		port_list = bit_array, \
		add_action = "add", \
		remove_action = "remove", \
		is_output = TRUE, \
		port_type = PORT_TYPE_NUMBER, \
		prefix = "Bit", \
		minimum_amount = 1, \
		maximum_amount = MAX_BITFIELD_SIZE \
	)
	number = add_input_port("Number", PORT_TYPE_NUMBER, order = 1.1)

/obj/item/circuit_component/binary_conversion/input_received(datum/port/input/port)
	if(!length(bit_array))
		return

	var/is_negative
	if(number.value < 0)
		is_negative = TRUE

	var/binary_representation = num2text((is_negative ? -number.value : number.value), length(bit_array), 2)
	for(var/iteration in 1 to length(bit_array))
		var/datum/port/output/bit = bit_array[iteration]
		if(is_negative && iteration == 1)
			bit.set_output(1)
			continue
		bit.set_output(text2num(binary_representation[iteration]))
