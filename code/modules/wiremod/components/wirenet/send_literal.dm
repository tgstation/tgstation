/obj/item/circuit_component/list_literal/wirenet_send
	display_name = "Wirenet Transmitter List Literal"
	desc = "Creates a list literal data package and sends it through the connected cable network. If Encryption Key is set then transmitted data will be only picked up by receivers with the same Encryption Key."
	category = "Utility"

	ui_buttons = list(
		"1" = CABLE_LAYER_1_NAME,
		"2" = CABLE_LAYER_2_NAME,
		"3" = CABLE_LAYER_3_NAME,
		"plus" = "add",
		"minus" = "remove",
	)

	var/cable_layer = /datum/component/circuit_component_wirenet_connection::cable_layer

	/// Powernet reference provided by the circuit_component_wirenet_connection component
	var/datum/powernet/connected_powernet

	/// Encryption key
	var/datum/port/input/enc_key

/obj/item/circuit_component/list_literal/wirenet_send/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/circuit_component_wirenet_connection,\
		connection_callback = CALLBACK(src, PROC_REF(on_powernet_connection)),\
		disconnection_callback = CALLBACK(src, PROC_REF(on_powernet_disconnection)),\
		post_set_cable_layer_callback = CALLBACK(src, PROC_REF(on_set_cable_layer)),\
	)

/obj/item/circuit_component/list_literal/wirenet_send/Destroy()
	. = ..()
	connected_powernet = null

/obj/item/circuit_component/list_literal/wirenet_send/proc/on_powernet_connection(datum/powernet/new_powernet)
	connected_powernet = new_powernet

/obj/item/circuit_component/list_literal/wirenet_send/proc/on_powernet_disconnection(datum/powernet/old_powernet)
	connected_powernet = null

/obj/item/circuit_component/list_literal/wirenet_send/proc/on_set_cable_layer(new_layer)
	cable_layer = new_layer

/obj/item/circuit_component/list_literal/wirenet_send/get_ui_notices()
	. = ..()
	. += create_ui_notice("Set the cable layer to connect to with the \"1\", \"2\", and \"3\" buttons.", "green", "info")
	. += create_ui_notice("Currently connected to: [GLOB.cable_layer_to_name["[cable_layer]"]]", "green", "info")

/obj/item/circuit_component/list_literal/wirenet_send/populate_ports()
	. = ..()
	enc_key = add_input_port("Encryption Key", PORT_TYPE_STRING)

/obj/item/circuit_component/list_literal/wirenet_send/input_received(datum/port/input/port)
	connected_powernet?.data_transmission(list_output.value, enc_key.value, WEAKREF(list_output))
