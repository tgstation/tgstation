/**
 * # NFC Transmitter Component
 *
 * Sends a data package through NFC
 * Only the targeted shell will receive the message
 */

/obj/item/circuit_component/nfc_send
	display_name = "NFC Transmitter"
	desc = "Sends a data package through NTNet. If Encryption Key is set then transmitted data will be only picked up by receivers with the same Encryption Key."
	category = "Utility"

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	/// The list type
	var/datum/port/input/option/list_options

	/// The targeted circuit
	var/datum/port/input/target

	/// Data being sent
	var/datum/port/input/data_package

	/// Encryption key
	var/datum/port/input/enc_key

/obj/item/circuit_component/nfc_send/populate_options()
	list_options = add_option_port("List Type", GLOB.wiremod_basic_types)

/obj/item/circuit_component/nfc_send/populate_ports()
	data_package = add_input_port("Data Package", PORT_TYPE_LIST(PORT_TYPE_ANY))
	enc_key = add_input_port("Encryption Key", PORT_TYPE_STRING)
	target = add_input_port("Target", PORT_TYPE_ATOM)

/obj/item/circuit_component/nfc_send/should_receive_input(datum/port/input/port)
	. = ..()
	if(!.)
		return FALSE

/obj/item/circuit_component/nfc_send/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_datatype = list_options.value
		data_package.set_datatype(PORT_TYPE_LIST(new_datatype))

/obj/item/circuit_component/nfc_send/input_received(datum/port/input/port)
	if(isatom(target.value))
		var/atom/target_enty = target.value
		SEND_SIGNAL(target_enty, COMSIG_CIRCUIT_NFC_DATA_SENT, parent, list("data" = data_package.value, "enc_key" = enc_key.value, "port" = WEAKREF(data_package)))
