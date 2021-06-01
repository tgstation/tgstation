/**
 * # Index Component
 *
 * Return the index of a list
 */
/obj/item/circuit_component/index
	display_name = "Index List"

	/// The input port
	var/datum/port/input/list_port
	var/datum/port/input/index_port

	/// The result from the output
	var/datum/port/output/output
	has_trigger = TRUE

/obj/item/circuit_component/index/Initialize()
	. = ..()
	index_port = add_input_port("Index", PORT_TYPE_ANY)
	list_port = add_input_port("List", PORT_TYPE_LIST)

	output = add_output_port("Value", PORT_TYPE_ANY)

/obj/item/circuit_component/index/Destroy()
	list_port = null
	index_port = null
	output = null
	return ..()

/obj/item/circuit_component/index/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/index = index_port.input_value
	var/list/list_input = list_port.input_value

	if(!islist(list_input) || !index)
		output.set_output(null)
		return

	if(isnum(index) && (index < 1 || index > length(list_input)))
		output.set_output(null)
		return

	output.set_output(list_input[index])
	trigger_output.set_output(COMPONENT_SIGNAL)
