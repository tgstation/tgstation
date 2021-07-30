/**
 * # HID Request Component
 *
 * When triggered outputs HID of target object
 */

/obj/item/circuit_component/get_hid
	display_name = "Hardware ID Request"
	display_desc = "Outputs Hardware ID of target object when triggered."

	var/datum/port/input/target_atom
	var/datum/port/output/result

/obj/item/circuit_component/get_hid/Initialize()
	. = ..()
	target_atom = add_input_port("Target", PORT_TYPE_ATOM)
	result = add_output_port("Hardware ID", PORT_TYPE_STRING)

/obj/item/circuit_component/get_hid/input_received(datum/port/input/port)
	. = ..()
	if(. || !target_atom.input_value)
		return
	var/atom/target = target_atom.input_value
	var/datum/component/ntnet_interface/target_interface = target.GetComponent(/datum/component/ntnet_interface)
	if(!target_interface)
		return
	result.set_output(target_interface.hardware_id)
