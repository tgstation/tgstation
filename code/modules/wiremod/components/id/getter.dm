/obj/item/circuit_component/id_getter
	display_name = "Get ID"
	desc = "A component that returns the first available ID card on an organism."
	category = "ID"

	/// The input port
	var/datum/port/input/target

	/// Whether to prioritize the target's hands when checking for an ID
	var/datum/port/input/prioritize_hands

	/// The reference to the ID
	var/datum/port/output/id_port

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/max_range = 1

/obj/item/circuit_component/id_getter/get_ui_notices()
	. = ..()
	. += create_ui_notice("Maximum Range: [max_range] tiles.", "orange", "info")

/obj/item/circuit_component/id_getter/populate_ports()
	target = add_input_port("Target", PORT_TYPE_ATOM)
	prioritize_hands = add_input_port("Prioritize Hands", PORT_TYPE_NUMBER)
	id_port = add_output_port("ID", PORT_TYPE_ATOM)

/obj/item/circuit_component/id_getter/input_received(datum/port/input/port)
	var/mob/living/target_mob = target.value
	var/turf/current_turf = get_location()
	if(!istype(target_mob) || get_dist(current_turf, target_mob) > max_range || current_turf.z != target_mob.z)
		id_port.set_output(null)
		return
	id_port.set_output(target_mob.get_idcard(prioritize_hands.value))
