/**
 * # Security Record Component
 *
 * Return the security records of a mob
 */
/obj/item/circuit_component/sec_status
	display_name = "Security Record"
	display_desc = "A component that returns the security records of an organism."

	/// The input port
	var/datum/port/input/target

	/// Name
	var/datum/port/output/target_name
	/// ID
	var/datum/port/output/id
	/// Criminal Status
	var/datum/port/output/criminal
	/// Crimes
	var/datum/port/output/crimes
	/// Notes
	var/datum/port/output/notes

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/max_range = 5

/obj/item/circuit_component/sec_status/get_ui_notices()
	. = ..()
	. += create_ui_notice("Maximum Range: [max_range] tiles", "orange", "info")

/obj/item/circuit_component/sec_status/Initialize(mapload)
	. = ..()
	target = add_input_port("Organism", PORT_TYPE_ATOM)

	target_name = add_output_port("Name", PORT_TYPE_STRING)
	id = add_output_port("ID", PORT_TYPE_STRING)
	criminal = add_output_port("Criminal Status", PORT_TYPE_STRING)
	crimes = add_output_port("Crimes", PORT_TYPE_LIST)
	notes = add_output_port("Notes", PORT_TYPE_STRING)

/obj/item/circuit_component/sec_status/Destroy()
	target = null
	target_name = null
	id = null
	criminal = null
	crimes = null
	notes = null
	return ..()

/obj/item/circuit_component/sec_status/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/mob/living/carbon/human/organism = target.input_value
	var/turf/current_turf = get_turf(src)
	if(!istype(organism))
		return
	var/perpname = organism.get_face_name(organism.get_id_name())
	var/datum/data/record/record = find_record("name", perpname, GLOB.data_core.security)
	if(get_dist(current_turf, organism) > max_range || current_turf.z != organism.z || !record)
		target_name.set_output(null)
		id.set_output(null)
		criminal.set_output(null)
		crimes.set_output(null)
		notes.set_output(null)
		return


	target_name.set_output(record.fields["name"])
	id.set_output(record.fields["id"])
	criminal.set_output(record.fields["criminal"])
	crimes.set_output(record.fields["crim"])
	notes.set_output(record.fields["notes"])
