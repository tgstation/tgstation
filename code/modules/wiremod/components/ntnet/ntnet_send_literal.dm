/**
 * # NTNet Transmitter List Literal Component
 *
 * Create a list literal and send a data package through NTNet
 *
 * This file is based off of ntnet_send.dm
 * Any changes made to those files should be copied over with discretion
 */
/obj/item/circuit_component/list_literal/ntnet_send
	display_name = "NTNet Transmitter List Literal"
	desc = "Creates a list literal data package and sends it through NTNet. If Encryption Key is set then transmitted data will be only picked up by receivers with the same Encryption Key."
	category = "NTNet"

	/// Encryption key
	var/datum/port/input/enc_key

/obj/item/circuit_component/list_literal/ntnet_send/populate_ports()
	. = ..()
	enc_key = add_input_port("Encryption Key", PORT_TYPE_STRING)

/obj/item/circuit_component/list_literal/ntnet_send/input_received(datum/port/input/port)
	if(!find_functional_ntnet_relay()) /// The server is down, don't send shit
		return

	. = ..()

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CIRCUIT_NTNET_DATA_SENT, list("data" = list_output.value, "enc_key" = enc_key.value, "port" = WEAKREF(list_output)))
