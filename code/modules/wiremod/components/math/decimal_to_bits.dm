/**
 * # Number to Bit Array Component
 *
 * Return an array (well, different outputs actually) of binary digits.
 */
/obj/item/circuit_component/binary_decimal/decimal_to_bit_array
	display_name = "Decimal Number To Binary Array"
	desc = "Splits a decimal number into an array of binary digits, or bits, represented as 1 or 0 and often used in boolean or binary operations like AND, OR and XOR. \
		Attack in hand to increase array size, right click to decrease array size."

/obj/item/circuit_component/binary_decimal/decimal_to_bit_array/populate_ports()
	. = ..()
	number = add_input_port("Number", PORT_TYPE_NUMBER)

/obj/item/circuit_component/binary_decimal/decimal_to_bit_array/add_bit_port(index)
	add_output_port("Bit [index]", PORT_TYPE_NUMBER)

/obj/item/circuit_component/binary_decimal/decimal_to_bit_array/remove_bit_port(datum/port/to_remove)
	remove_output_port(to_remove)

/obj/item/circuit_component/binary_decimal/decimal_to_bit_array/input_received(datum/port/input/port)
	if(!array_size)
		return

	for(var/iteration in 1 to array_size)
		var/datum/port/output/bit = bit_array[iteration]
		bit.set_output(number.value & (2 ** (iteration - 1)))
