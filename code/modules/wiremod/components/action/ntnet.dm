/**
 * # NTNet Transmitter Component
 *
 * Sends a data package through NTNet
 */

/obj/item/circuit_component/ntnet
	display_name = "NTNet Transmitter/Receiver"
	desc = "Sends and recieves data packages through NTNet. If Encryption Key is set then transmitted data will be only picked up by NTNet components with the same Encryption Key."

	//circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	network_id = __NETWORK_CIRCUITS

	var/datum/port/input/option/data_type_options
	var/datum/port/input/option/secondary_data_type_options

	var/datum/port/input/data_package
	var/datum/port/input/secondary_package
	var/datum/port/input/enc_key

	var/datum/port/output/hid
	var/datum/port/output/data_package_received
	var/datum/port/output/secondary_package_received

/obj/item/circuit_component/ntnet/Initialize()
	. = ..()
	data_package = add_input_port("Data Package", PORT_TYPE_ANY, FALSE)
	secondary_package = add_input_port("Secondary Package", PORT_TYPE_ANY, FALSE)

	data_package_received = add_output_port("Received Data Package", PORT_TYPE_ANY)
	secondary_package_received = add_output_port("Received Secondary Package", PORT_TYPE_ANY)

	enc_key = add_input_port("Encryption Key", PORT_TYPE_STRING, FALSE)

	trigger_input = add_input_port("Send", PORT_TYPE_SIGNAL)
	trigger_output = add_output_port("Received", PORT_TYPE_SIGNAL)

	RegisterSignal(src, COMSIG_COMPONENT_NTNET_RECEIVE, .proc/ntnet_receive)

/obj/item/circuit_component/ntnet/populate_options()
	var/static/component_options = list(
		PORT_TYPE_ANY,
		PORT_TYPE_STRING,
		PORT_TYPE_NUMBER,
		PORT_TYPE_LIST,
		PORT_TYPE_ATOM,
	)
	data_type_options = add_option_port("Received Data Type", component_options)
	secondary_data_type_options = add_option_port("Secondary Received Data Type", component_options)


/obj/item/circuit_component/ntnet/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(COMPONENT_TRIGGERED_BY(data_type_options, port))
		data_package_received.set_datatype(data_type_options.value)
		return

	if(COMPONENT_TRIGGERED_BY(secondary_data_type_options, port))
		secondary_package_received.set_datatype(secondary_data_type_options.value)
		return

	ntnet_send(list("data" = data_package.value, "data_secondary" = secondary_package.value, "enc_key" = enc_key.value, "origin" = src))

/obj/item/circuit_component/ntnet/proc/ntnet_receive(datum/source, datum/netdata/data)
	SIGNAL_HANDLER

	if(data.data["enc_key"] != enc_key.value)
		return
	if(data.data["origin"] == src)
		return

	data_package_received.set_output(data.data["data"])
	secondary_package_received.set_output(data.data["data_secondary"])
	trigger_output.set_output(COMPONENT_SIGNAL)
