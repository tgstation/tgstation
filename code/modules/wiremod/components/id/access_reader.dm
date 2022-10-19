/obj/item/circuit_component/id_access_reader
	display_name = "Read ID Access"
	desc = "A component that reads the access on an ID."
	category = "ID"

	/// The input port
	var/datum/port/input/target

	/// A list of the accesses on the ID
	var/datum/port/output/access_port

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/max_range = 1

/obj/item/circuit_component/id_access_reader/get_ui_notices()
	. = ..()
	. += create_ui_notice("Maximum Range: [max_range] tiles.", "orange", "info")

/obj/item/circuit_component/id_access_reader/populate_ports()
	target = add_input_port("Target", PORT_TYPE_ATOM)
	access_port = add_output_port("Access", PORT_TYPE_LIST(PORT_TYPE_STRING))


/obj/item/circuit_component/id_access_reader/input_received(datum/port/input/port)
	var/obj/item/card/id/target_item = target.value
	var/turf/current_turf = get_location()
	var/turf/target_turf = get_turf(target_item)
	if(!istype(target_item) || get_dist(current_turf, target_turf) > max_range || current_turf.z != target_turf.z)
		access_port.set_output(null)
		return
	access_port.set_output(target_item.GetAccess())
