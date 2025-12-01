/obj/item/circuit_component/wirenet_send
	display_name = "Wirenet Transmitter"
	desc = "Sends a data package through the connected cable network. If Encryption Key is set then transmitted data will be only picked up by receivers with the same Encryption Key."
	category = "Utility"

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	ui_buttons = list(
		"1" = CABLE_LAYER_1_NAME,
		"2" = CABLE_LAYER_2_NAME,
		"3" = CABLE_LAYER_3_NAME,
	)

	var/cable_layer = /datum/component/circuit_component_wirenet_connection::cable_layer

	/// Powernet reference provided by the circuit_component_wirenet_connection component
	var/datum/powernet/connected_powernet

	/// The list type
	var/datum/port/input/option/list_options

	/// Data being sent
	var/datum/port/input/data_package

	/// Encryption key
	var/datum/port/input/enc_key

/obj/item/circuit_component/wirenet_send/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/circuit_component_wirenet_connection,\
		connection_callback = CALLBACK(src, PROC_REF(on_powernet_connection)),\
		disconnection_callback = CALLBACK(src, PROC_REF(on_powernet_disconnection)),\
		post_set_cable_layer_callback = CALLBACK(src, PROC_REF(on_set_cable_layer)),\
	)

/obj/item/circuit_component/wirenet_send/Destroy()
	. = ..()
	connected_powernet = null

/obj/item/circuit_component/wirenet_send/proc/on_powernet_connection(datum/powernet/new_powernet)
	connected_powernet = new_powernet

/obj/item/circuit_component/wirenet_send/proc/on_powernet_disconnection(datum/powernet/old_powernet)
	connected_powernet = null

/obj/item/circuit_component/wirenet_send/proc/on_set_cable_layer(new_layer)
	cable_layer = new_layer

/obj/item/circuit_component/wirenet_send/get_ui_notices()
	. = ..()
	. += create_ui_notice("Set the cable layer to connect to with the \"1\", \"2\", and \"3\" buttons.", "green", "info")
	. += create_ui_notice("Currently connected to: [GLOB.cable_layer_to_name["[cable_layer]"]]", "green", "info")

/obj/item/circuit_component/wirenet_send/populate_options()
	list_options = add_option_port("List Type", GLOB.wiremod_basic_types)

/obj/item/circuit_component/wirenet_send/populate_ports()
	data_package = add_input_port("Data Package", PORT_TYPE_LIST(PORT_TYPE_ANY))
	enc_key = add_input_port("Encryption Key", PORT_TYPE_STRING)

/obj/item/circuit_component/wirenet_send/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_datatype = list_options.value
		data_package.set_datatype(PORT_TYPE_LIST(new_datatype))

/obj/item/circuit_component/wirenet_send/input_received(datum/port/input/port)
	connected_powernet?.data_transmission(data_package.value, enc_key.value, WEAKREF(data_package))
