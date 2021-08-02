/**
 * # Spawn Atom Component
 *
 * Spawns an atom.
 */
/obj/item/circuit_component/spawn_atom
	display_name = "Spawn Atom"
	desc = "A component that returns the value of a list at a given index."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	/// The input path to convert into a typepath
	var/datum/port/input/input_path

	/// The turf to spawn them at
	var/datum/port/input/spawn_at

	/// Parameters to pass to the atom being spawned
	var/datum/port/input/parameters

	/// The result from the output
	var/datum/port/output/spawned_atom

/obj/item/circuit_component/spawn_atom/Initialize()
	. = ..()
	input_path = add_input_port("Type", PORT_TYPE_ANY)
	spawn_at = add_input_port("Spawn At", PORT_TYPE_ATOM)
	parameters = add_input_port("Parameters", PORT_TYPE_LIST)

	spawned_atom = add_output_port("Spawned Atom", PORT_TYPE_ATOM)

/obj/item/circuit_component/spawn_atom/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/typepath = input_path.input_value

	if(!ispath(typepath, /atom))
		return

	var/list/params = parameters.input_value
	if(!params)
		params = list()

	params.Insert(1, spawn_at.input_value)

	spawned_atom.set_output(new typepath(arglist(params)))
