/**
 * # NTNet Request Component
 *
 * Sends a data package through NTNet
 */

/obj/item/circuit_component/ntnet_send
	display_name = "NTNet Request"
	display_desc = "Sends a data package through NTNet when triggered. If target HID is not provided, data will be sent to all circuits in the network."

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	network_id = __NETWORK_CIRCUITS

	var/datum/port/input/target_hid
	var/datum/port/input/data_package
	var/datum/port/input/secondary_package

/obj/item/circuit_component/ntnet_send/Initialize()
	. = ..()
	target_hid = add_input_port("Target HID", PORT_TYPE_STRING)
	data_package = add_input_port("Data Package", PORT_TYPE_ANY)
	secondary_package = add_input_port("Secondary Package", PORT_TYPE_ANY)

/obj/item/circuit_component/ntnet_send/input_received(datum/port/input/port)
	. = ..()
	if(. || !data_package.input_value)
		return

	var/list/datalist = list("data" = data_package.input_value)
	if(secondary_package.input_value)
		datalist["data_secondary"] = secondary_package.input_value
	var/datum/netdata/data = new(datalist)
	data.receiver_id = target_hid.input_value ? target_hid.input_value : __NETWORK_CIRCUITS
	ntnet_send(data)
