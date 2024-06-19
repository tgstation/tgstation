/**
 * # Material Scanner
 *
 * Returns the materials of an atom
 */
/obj/item/circuit_component/matscanner
	display_name = "Material Scanner"
	desc = "Outputs the material composition of the inputted entity."
	category = "Entity"

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	// The entity to scan
	var/datum/port/input/input_port
	/// Whether we consider the materials alloys are made when scanning.
	var/datum/port/input/break_down_alloys
	/// The result from the output
	var/datum/port/output/result

	var/max_range = 5

/obj/item/circuit_component/matscanner/get_ui_notices()
	. = ..()
	. += create_ui_notice("Maximum Range: [max_range] tiles", "orange", "info")

/obj/item/circuit_component/matscanner/populate_ports()
	input_port = add_input_port("Entity", PORT_TYPE_ATOM)
	break_down_alloys = add_input_port("Break Down Alloys", PORT_TYPE_NUMBER)
	result = add_output_port("Materials", PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, PORT_TYPE_NUMBER))

/obj/item/circuit_component/matscanner/input_received(datum/port/input/port)
	var/atom/entity = input_port.value
	var/turf/location = get_location()
	if(!istype(entity) || !IN_GIVEN_RANGE(location, entity, max_range))
		result.set_output(null)
		return
	var/list/composition = entity.get_material_composition()
	var/list/composition_but_with_string_keys = list()
	for(var/datum/material/material as anything in composition)
		composition_but_with_string_keys[material.name] = composition[material]
	result.set_output(composition_but_with_string_keys)
