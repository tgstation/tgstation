/**
 * # Reagents Scanner
 *
 * Returns the reagentss of an atom
 */
/obj/item/circuit_component/reagentscanner
	display_name = "Reagents Scanner"
	desc = "Outputs the reagents found inside the inputted entity."
	category = "Entity"

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	// The entity to scan
	var/datum/port/input/input_port
	/// The result from the output
	var/datum/port/output/result

	var/max_range = 5

/obj/item/circuit_component/reagentscanner/get_ui_notices()
	. = ..()
	. += create_ui_notice("Maximum Range: [max_range] tiles", "orange", "info")
	. += create_table_notices(list(
		"reagent",
		"volume",
		))

/obj/item/circuit_component/reagentscanner/populate_ports()
	input_port = add_input_port("Entity", PORT_TYPE_ATOM)
	result = add_output_port("Reagents", PORT_TYPE_TABLE)

/obj/item/circuit_component/reagentscanner/input_received(datum/port/input/port)
	var/atom/entity = input_port.value
	var/turf/location = get_location()
	if(!istype(entity) || !IN_GIVEN_RANGE(location, entity, max_range))
		result.set_output(null)
		return
	var/list/new_table = list()
	for(var/datum/reagent/reagent as anything in entity.reagents?.reagent_list)
		var/list/entry = list()
		entry["reagent"] = reagent.name
		entry["volume"] = reagent.volume
		new_table += list(entry)
	result.set_output(new_table)
