/**
 * # NTNet Reciever Component
 *
 * Recieves data through NTNet.
 */

/obj/item/circuit_component/ntnet_receive
	display_name = "NTNet Receiver"
	display_desc = "Recieves data packages through NTNet."

	circuit_flags = CIRCUIT_FLAG_OUTPUT_SIGNAL //trigger_output

	network_id = __NETWORK_CIRCUITS

	var/datum/port/input/push_hid
	var/datum/port/output/hid
	var/datum/port/output/data_package
	var/datum/port/output/secondary_package

/obj/item/circuit_component/ntnet_receive/Initialize()
	. = ..()
	AddComponent(/datum/component/ntnet_interface)
	push_hid = add_input_port("Get Hardware ID", PORT_TYPE_SIGNAL)
	hid = add_output_port("Hardware ID", PORT_TYPE_STRING)
	data_package = add_output_port("Data Package", PORT_TYPE_ANY)
	secondary_package = add_output_port("Secondary Package", PORT_TYPE_ANY)
	RegisterSignal(src, COMSIG_COMPONENT_NTNET_RECEIVE, .proc/ntnet_receive)

/obj/item/circuit_component/ntnet_receive/populate_options()
	var/static/component_options = list(
		PORT_TYPE_ANY,
		PORT_TYPE_STRING,
		PORT_TYPE_NUMBER,
		PORT_TYPE_LIST,
		PORT_TYPE_ATOM,
	)
	options = component_options

/obj/item/circuit_component/ntnet_receive/set_option(option)
	. = ..()
	data_package.set_datatype(option)
	secondary_package.set_datatype(option)

/obj/item/circuit_component/ntnet_receive/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/datum/component/ntnet_interface/ntnet_interface = GetComponent(/datum/component/ntnet_interface)
	hid.set_output(ntnet_interface.hardware_id)

/obj/item/circuit_component/ntnet_receive/proc/ntnet_receive(datum/source, datum/netdata/data)
	SIGNAL_HANDLER

	data_package.set_output(data.data["data"])
	secondary_package.set_output(data.data["data_secondary"])
	trigger_output.set_output(COMPONENT_SIGNAL)
