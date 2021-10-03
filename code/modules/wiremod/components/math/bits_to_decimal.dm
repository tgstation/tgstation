/**
 * # Bit Array to Number Component
 *
 * Return an array (well, different outputs actually) of binary digits.
 */
/obj/item/circuit_component/binary_decimal/bit_array_to_decimal
	display_name = "Binary Array To Decimal Number"
	desc = "Merges an array of binary digits, or bits, represented as 1 or 0 and often used in boolean or binary operations, into a decimal number. \
		Attack in hand to increase array size, right click to decrease array size."

/obj/item/circuit_component/binary_decimal/bit_array_to_decimal/populate_ports()
	. = ..()
	number = add_output_port("Number", PORT_TYPE_NUMBER)

/obj/item/circuit_component/binary_decimal/bit_array_to_decimal/add_bit_port(index)
	add_input_port("Bit [index]", PORT_TYPE_NUMBER)

/obj/item/circuit_component/binary_decimal/bit_array_to_decimal/remove_bit_port(datum/port/to_remove)
	remove_input_port(to_remove)

/obj/item/circuit_component/binary_decimal/bit_array_to_decimal/input_received(datum/port/input/port)
	if(!array_size)
		return

	var/result = 0
	for(var/iteration in 1 to array_size)
		var/datum/port/input/bit = bit_array[iteration]
		if(bit.value)
			result += (2 ** (iteration-1))
	number.set_output(result)
