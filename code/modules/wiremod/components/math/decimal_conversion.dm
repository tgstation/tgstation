/**
 * # Decimal Conversion Component
 *
 * Return a number from an array of binary inputs.
 */
/obj/item/circuit_component/binary_decimal/decimal_conversion
	display_name = "Decimal Conversion"
	desc = "Merges an array of binary digits, or bits, represented as 1 or 0 and often used in boolean or binary operations, into a decimal number."
	category = "Math"

/obj/item/circuit_component/binary_decimal/decimal_conversion/populate_ports()
	. = ..()
	number = add_output_port("Number", PORT_TYPE_NUMBER)

/obj/item/circuit_component/binary_decimal/decimal_conversion/add_bit_port(index)
	return add_input_port("Bit [index]", PORT_TYPE_NUMBER)

/obj/item/circuit_component/binary_decimal/decimal_conversion/remove_bit_port(datum/port/to_remove)
	return remove_input_port(to_remove)

/obj/item/circuit_component/binary_decimal/decimal_conversion/input_received(datum/port/input/port)
	if(!array_size)
		return

	var/result = 0
	for(var/iteration in 1 to array_size)
		var/datum/port/input/bit = bit_array[iteration]
		if(bit.value)
			result += (2 ** (iteration-1))
	number.set_output(result)
