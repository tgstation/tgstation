/**
 * # Get Health Component
 *
 * Return the health of a mob
 */
/obj/item/circuit_component/health
	display_name = "Get Health"
	desc = "A component that returns the health of an organism."
	category = "Entity"

	/// The input port
	var/datum/port/input/input_port

	/// Brute damage
	var/datum/port/output/brute
	/// Burn damage
	var/datum/port/output/burn
	/// Toxin damage
	var/datum/port/output/toxin
	/// Oxyloss damage
	var/datum/port/output/oxy
	/// Health
	var/datum/port/output/health

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/max_range = 5

/obj/item/circuit_component/health/get_ui_notices()
	. = ..()
	. += create_ui_notice("Maximum Range: [max_range] tiles", "orange", "info")

/obj/item/circuit_component/health/populate_ports()
	input_port = add_input_port("Organism", PORT_TYPE_ATOM)

	brute = add_output_port("Brute Damage", PORT_TYPE_NUMBER)
	burn = add_output_port("Burn Damage", PORT_TYPE_NUMBER)
	toxin = add_output_port("Toxin Damage", PORT_TYPE_NUMBER)
	oxy = add_output_port("Suffocation Damage", PORT_TYPE_NUMBER)
	health = add_output_port("Health", PORT_TYPE_NUMBER)

/obj/item/circuit_component/health/input_received(datum/port/input/port)

	var/mob/living/organism = input_port.value
	var/turf/current_turf = get_location()
	if(!istype(organism) || get_dist(current_turf, organism) > max_range || current_turf.z != organism.z)
		brute.set_output(null)
		burn.set_output(null)
		toxin.set_output(null)
		oxy.set_output(null)
		health.set_output(null)
		return

	brute.set_output(organism.getBruteLoss())
	burn.set_output(organism.getFireLoss())
	toxin.set_output(organism.getToxLoss())
	oxy.set_output(organism.getOxyLoss())
	health.set_output(organism.health)

