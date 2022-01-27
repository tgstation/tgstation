/**
 * # Spawn Atom Component
 *
 * Spawns an atom.
 */
/obj/item/circuit_component/spawn_atom
	display_name = "Spawn Atom"
	desc = "Spawns an atom at a desired location"
	category = "Admin"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	/// The input path to convert into a typepath
	var/datum/port/input/input_path

	/// The turf to spawn them at
	var/datum/port/input/spawn_at

	/// Parameters to pass to the atom being spawned
	var/datum/port/input/parameters

	/// The result from the output
	var/datum/port/output/spawned_atom

/obj/item/circuit_component/spawn_atom/populate_ports()
	input_path = add_input_port("Type", PORT_TYPE_ANY)
	spawn_at = add_input_port("Spawn At", PORT_TYPE_ATOM)
	parameters = add_input_port("Parameters", PORT_TYPE_LIST(PORT_TYPE_ANY))

	spawned_atom = add_output_port("Spawned Atom", PORT_TYPE_ATOM)

/obj/item/circuit_component/spawn_atom/input_received(datum/port/input/port)

	var/typepath = input_path.value

	if(!ispath(typepath, /atom))
		return

	var/list/params = parameters.value
	if(!params)
		params = list()

	var/list/resolved_params = recursive_list_resolve(params)

	resolved_params.Insert(1, spawn_at.value)

	var/atom/spawned = new typepath(arglist(resolved_params))
	spawned.datum_flags |= DF_VAR_EDITED
	spawned_atom.set_output(spawned)
