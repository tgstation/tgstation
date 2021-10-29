/**
 * # Binary Conversion Component
 *
 * Return an array of binary digits from a number input.
 */
/obj/item/circuit_component/binary_decimal/binary_conversion
	display_name = "Binary Conversion"
	desc = "Splits a decimal number into an array of binary digits, or bits, represented as 1 or 0 and often used in boolean or binary operations like AND, OR and XOR."
	category = "Math"

/obj/item/circuit_component/binary_decimal/binary_conversion/populate_ports()
	. = ..()
	number = add_input_port("Number", PORT_TYPE_NUMBER)

/obj/item/circuit_component/binary_decimal/binary_conversion/add_bit_port(index)
	return add_output_port("Bit [index]", PORT_TYPE_NUMBER)

/obj/item/circuit_component/binary_decimal/binary_conversion/remove_bit_port(datum/port/to_remove)
	return remove_output_port(to_remove)

/obj/item/circuit_component/binary_decimal/binary_conversion/input_received(datum/port/input/port)
	if(!array_size)
		return

	for(var/iteration in 1 to array_size)
		var/datum/port/output/bit = bit_array[iteration]
		bit.set_output(number.value & (2 ** (iteration - 1)))
