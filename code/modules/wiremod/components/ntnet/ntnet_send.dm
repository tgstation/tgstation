/**
 * # NTNet Transmitter Component
 *
 * Sends a data package through NTNet
 */

/obj/item/circuit_component/ntnet_send
	display_name = "NTNet Transmitter"
	desc = "Sends a data package through NTNet. If Encryption Key is set then transmitted data will be only picked up by receivers with the same Encryption Key."

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	network_id = __NETWORK_CIRCUITS

	var/datum/port/input/data_package
	var/datum/port/input/secondary_package
	var/datum/port/input/enc_key

/obj/item/circuit_component/ntnet_send/populate_ports()
	data_package = add_input_port("Data Package", PORT_TYPE_ANY)
	secondary_package = add_input_port("Secondary Package", PORT_TYPE_ANY)
	enc_key = add_input_port("Encryption Key", PORT_TYPE_STRING)

/obj/item/circuit_component/ntnet_send/input_received(datum/port/input/port)
	ntnet_send(list("data" = data_package.value, "data_secondary" = secondary_package.value, "enc_key" = enc_key.value))
