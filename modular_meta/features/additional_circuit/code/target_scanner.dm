/**
 * # Target Scanner Component
 *
 * Allows for creating a list of atoms within a range of 1.
 */
/obj/item/circuit_component/target_scanner
	display_name = "Target Scanner"
	desc = "A component that will create a list of the things within a location depending on an offset to the shell."
	category = "Action"

	// the offsets required for scanning
	var/datum/port/input/x_pos
	var/datum/port/input/y_pos

	COOLDOWN_DECLARE(scan_delay)
	///the delay between each scan
	var/time_delay = 0.5 SECONDS

	/// The table filled of atoms or "entities"
	var/datum/port/output/atom_table

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/target_scanner/populate_ports()
	x_pos = add_input_port("X offset", PORT_TYPE_NUMBER)
	y_pos = add_input_port("Y offset", PORT_TYPE_NUMBER)
	atom_table = add_output_port("Output", PORT_TYPE_LIST(PORT_TYPE_ATOM))

/obj/item/circuit_component/target_scanner/input_received(datum/port/input/port)
	//cooldown is important
	if(!COOLDOWN_FINISHED(src, scan_delay))
		return
	COOLDOWN_START(src, scan_delay, time_delay)
	//we need both a x pos and y pos
	if(!x_pos || !y_pos)
		return
	//the turf that will be scanned
	var/turf/target_turf = locate(parent.shell.x + x_pos.value, parent.shell.y + y_pos.value, parent.shell.z)
	//for sanity
	if(!target_turf)
		return
	//null the create_table
	var/create_table = list()
	//add the scanned turf to the create_table
	create_table += target_turf
	//add the contents of the scanned turf to create_table
	for(var/iteration in target_turf.contents)
		create_table += iteration
	//send out the table
	atom_table.set_output(create_table)
