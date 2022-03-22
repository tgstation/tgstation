/**
 * # Binary Decimal Component
 *
 * Has a bit array on one side and a decimal number on the other.
 */
/obj/item/circuit_component/binary_decimal
	display_name = "Decimal - Bit Array"
	desc = "Splits a decimal number into an array of binary digits and vicecersa."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// One number
	var/datum/port/output/number

	/// Many binary digits
	var/list/datum/port/bit_array = list()

	var/array_size = 0

	var/default_array_size = 8

	var/min_size = 1 //Who in their right mind would use a 1-bit array for circuits anyway?
	var/max_size = MAX_BITFIELD_SIZE

	ui_buttons = list(
		"plus" = "increase",
		"minus" = "decrease"
	)

/obj/item/circuit_component/binary_decimal/save_data_to_list(list/component_data)
	. = ..()
	component_data["array_size"] = array_size

/obj/item/circuit_component/binary_decimal/load_data_from_list(list/component_data)
	set_array_size(component_data["array_size"])
	return ..()

/obj/item/circuit_component/binary_decimal/proc/set_array_size(new_size)
	if(new_size <= 0)
		for(var/datum/port/port in bit_array)
			remove_bit_port(port)
		bit_array = list()
		array_size = 0
		return

	while(array_size > new_size)
		var/index = length(bit_array)
		var/datum/port/output = bit_array[index]
		bit_array -= output
		remove_bit_port(output)
		array_size--

	while(array_size < new_size)
		array_size++
		var/index = length(bit_array)
		bit_array += add_bit_port(index)

/obj/item/circuit_component/binary_decimal/proc/add_bit_port(index)
	return

/obj/item/circuit_component/binary_decimal/proc/remove_bit_port(datum/port/to_remove)
	return

/obj/item/circuit_component/binary_decimal/populate_ports()
	set_array_size(default_array_size)

// Increase or decrease the array size
/obj/item/circuit_component/binary_decimal/ui_perform_action(mob/user, action)
	switch(action)
		if("increase")
			set_array_size(min(array_size + 1, max_size))
		if("decrease")
			set_array_size(max(array_size - 1, min_size))
