// Helpers for saving/loading integrated circuits.


// Saves type, modified name and modified inputs (if any) to a list
// The list is converted to JSON down the line.
//"Special" is not verified at any point except for by the circuit itself.
/obj/item/integrated_circuit/proc/save()
	var/list/circuit_params = list()
	var/init_name = initial(name)

	// Save initial name used for differentiating assemblies
	circuit_params["type"] = init_name

	// Save the modified name.
	if(init_name != displayed_name)
		circuit_params["name"] = displayed_name

	// Saving input values
	if(length(inputs))
		var/list/saved_inputs = list()

		for(var/index in 1 to inputs.len)
			var/datum/integrated_io/input = inputs[index]

			// Don't waste space saving the default values
			if(input.data == inputs_default["[index]"])
				continue
			if(input.data == initial(input.data))
				continue

			var/list/input_value = list(index, FALSE, input.data)
			// Index, Type, Value
			// FALSE is default type used for num/text/list/null
			// TODO: support for special input types, such as internal refs and maybe typepaths

			if(islist(input.data) || isnum(input.data) || istext(input.data) || isnull(input.data))
				saved_inputs.Add(list(input_value))

		if(saved_inputs.len)
			circuit_params["inputs"] = saved_inputs

	var/special = save_special()
	if(!isnull(special))
		circuit_params["special"] = special

	return circuit_params

/obj/item/integrated_circuit/proc/save_special()
	return

// Verifies a list of circuit parameters
// Returns null on success, error name on failure
/obj/item/integrated_circuit/proc/verify_save(list/circuit_params)
	var/init_name = initial(name)
	// Validate name
	if(circuit_params["name"] && !reject_bad_name(circuit_params["name"], TRUE))
		return "Bad circuit name at [init_name]."

	// Validate input values
	if(circuit_params["inputs"])
		var/list/loaded_inputs = circuit_params["inputs"]
		if(!islist(loaded_inputs))
			return "Malformed input values list at [init_name]."

		var/inputs_amt = length(inputs)

		// Too many inputs? Inputs for input-less circuit? This is not good.
		if(!inputs_amt || inputs_amt < length(loaded_inputs))
			return "Input values list out of bounds at [init_name]."

		for(var/list/input in loaded_inputs)
			if(input.len != 3)
				return "Malformed input data at [init_name]."

			var/input_id = input[1]
			var/input_type = input[2]
			//var/input_value = input[3]

			// No special type support yet.
			if(input_type)
				return "Unidentified input type at [init_name]!"
			// TODO: support for special input types, such as typepaths and internal refs

			// Input ID is a list index, make sure it's sane.
			if(!isnum(input_id) || input_id % 1 || input_id > inputs_amt || input_id < 1)
				return "Invalid input index at [init_name]."


// Loads circuit parameters from a list
// Doesn't verify any of the parameters it loads, this is the job of verify_save()
/obj/item/integrated_circuit/proc/load(list/circuit_params)
	// Load name
	if(circuit_params["name"])
		displayed_name = circuit_params["name"]

	// Load input values
	if(circuit_params["inputs"])
		var/list/loaded_inputs = circuit_params["inputs"]

		for(var/list/input in loaded_inputs)
			var/index = input[1]
			//var/input_type = input[2]
			var/input_value = input[3]

			var/datum/integrated_io/pin = inputs[index]
			// The pins themselves validate the data.
			pin.write_data_to_pin(input_value)
			// TODO: support for special input types, such as internal refs and maybe typepaths

	if(!isnull(circuit_params["special"]))
		load_special(circuit_params["special"])

/obj/item/integrated_circuit/proc/load_special(special_data)
	return

// Saves type and modified name (if any) to a list
// The list is converted to JSON down the line.
/datum/component/integrated_electronic/proc/save()
	var/list/assembly_params = list()

	// Save initial name used for differentiating assemblies
	assembly_params["type"] = initial(assembly_atom.name)

	// Save modified name
	if(initial(assembly_atom.name) != assembly_atom.name)
		assembly_params["name"] = assembly_atom.name

	// Save modified description
	if(initial(assembly_atom.desc) != assembly_atom.desc)
		assembly_params["desc"] = assembly_atom.desc

	// Save modified color
	if(initial(detail_color) != detail_color)
		assembly_params["detail_color"] = detail_color

	return assembly_params


// Verifies a list of assembly parameters
// Returns null on success, error name on failure
/datum/controller/subsystem/processing/circuit/proc/verify_save(list/assembly_params)
	// Validate name and color
	if(assembly_params["name"] && !reject_bad_name(assembly_params["name"], TRUE))
		return "Bad assembly name."
	if(assembly_params["desc"] && !reject_bad_text(assembly_params["desc"]))
		return "Bad assembly description."
	if(assembly_params["detail_color"] && !(assembly_params["detail_color"] in color_whitelist))
		return "Bad assembly color."

// Loads assembly parameters from a list
// Doesn't verify any of the parameters it loads, this is the job of verify_save()
/datum/component/integrated_electronic/proc/load(list/assembly_params)
	// Load modified name, if any.
	if(assembly_params["name"])
		assembly_atom.name = assembly_params["name"]

	// Load modified description, if any.
	if(assembly_params["desc"])
		assembly_atom.desc = assembly_params["desc"]

	if(assembly_params["detail_color"])
		detail_color = assembly_params["detail_color"]

	var/obj/assembly_obj = parent
	if(assembly_obj)
		assembly_obj.update_icon()



// Attempts to save an assembly into a save file format.
// Returns null if assembly is not complete enough to be saved.
/datum/controller/subsystem/processing/circuit/proc/save_electronic_assembly(datum/component/integrated_electronic/assembly)
	// No circuits? Don't even try to save it.
	if(!length(assembly.assembly_circuits))
		return


	var/list/blocks = list()

	// Block 1. Assembly.
	blocks["assembly"] = assembly.save()
	// (implant assemblies are not yet supported)


	// Block 2. Circuits.
	var/list/circuits = list()
	for(var/c in assembly.assembly_circuits)
		var/obj/item/integrated_circuit/circuit = c
		circuits.Add(list(circuit.save()))
	blocks["components"] = circuits


	// Block 3. Wires.
	var/list/wires = list()
	var/list/saved_wires = list()

	for(var/c in assembly.assembly_circuits)
		var/obj/item/integrated_circuit/circuit = c
		var/list/all_pins = circuit.inputs + circuit.outputs + circuit.activators

		for(var/p in all_pins)
			var/datum/integrated_io/pin = p
			var/list/params = pin.get_pin_parameters()
			var/text_params = params.Join()

			for(var/p2 in pin.linked)
				var/datum/integrated_io/pin2 = p2
				var/list/params2 = pin2.get_pin_parameters()
				var/text_params2 = params2.Join()

				// Check if we already saved an opposite version of this wire
				// (do not save the same wire twice)
				if((text_params2 + "=" + text_params) in saved_wires)
					continue

				// If not, add a wire "hash" for future checks and save it
				saved_wires.Add(text_params + "=" + text_params2)
				wires.Add(list(list(params, params2)))

	if(wires.len)
		blocks["wires"] = wires

	return json_encode(blocks)



// Checks assembly save and calculates some of the parameters.
// Returns assembly (type: list) if the save is valid.
// Returns error code (type: text) if loading has failed.
// The following parameters area calculated during validation and added to the returned save list:
// "requires_upgrades", "unsupported_circuit", "metal_cost", "complexity", "max_complexity", "used_space", "max_space"
/datum/controller/subsystem/processing/circuit/proc/validate_electronic_assembly(program)
	var/list/blocks = json_decode(program)
	if(!blocks)
		return

	var/error


	// Block 1. Assembly.
	var/list/assembly_params = blocks["assembly"]

	if(!islist(assembly_params) || !length(assembly_params))
		return "Invalid assembly data."	// No assembly, damaged assembly or empty assembly

	// Validate type, get a temporary circuit
	var/assembly_path = all_assemblies[assembly_params["type"]]
	var/atom/assembly_atom = cached_assemblies[assembly_path]
	var/datum/component/integrated_electronic/assembly = assembly_atom.GetComponent(/datum/component/integrated_electronic)
	if(!assembly)
		return "Invalid assembly type."

	// Check assembly save data for errors
	error = verify_save(assembly_params)
	if(error)
		return error


	// Read space & complexity limits and start keeping track of them
	blocks["complexity"] = 0
	blocks["max_complexity"] = assembly.max_complexity
	blocks["used_space"] = 0
	blocks["max_space"] = assembly.max_circuits
	blocks["metal_cost"] = IC_GET_COST(assembly.max_circuits, assembly.max_complexity)


	// Block 2. Circuits.
	if(!islist(blocks["components"]) || !length(blocks["components"]))
		return "Invalid circuits list."	// No circuits or damaged circuits list

	var/list/assembly_circuits = list()
	for(var/C in blocks["components"])
		var/list/circuit_params = C

		if(!islist(circuit_params) || !length(circuit_params))
			return "Invalid circuit data."

		// Validate type, get a temporary circuit
		var/circuit_path = all_circuits[circuit_params["type"]]
		var/obj/item/integrated_circuit/circuit = cached_circuits[circuit_path]
		if(!circuit)
			return "Invalid circuit type."

		// Add temporary circuit to assembly_circuits list, to be used later when verifying the wires
		assembly_circuits.Add(circuit)

		// Check circuit save data for errors
		error = circuit.verify_save(circuit_params)
		if(error)
			return error

		// Update estimated assembly complexity, taken space and material cost
		blocks["complexity"] += circuit.complexity
		blocks["used_space"] += circuit.size
		blocks["metal_cost"] += circuit.materials[MAT_METAL]

		// Check if the assembly requires printer upgrades
		if(!(circuit.spawn_flags & IC_SPAWN_DEFAULT))
			blocks["requires_upgrades"] = TRUE

		// Check if the assembly supports the circucit
		if((circuit.action_flags & assembly.allowed_circuit_action_flags) != circuit.action_flags)
			blocks["unsupported_circuit"] = TRUE


	// Check complexity and space limitations
	if(blocks["used_space"] > blocks["max_space"])
		return "Used space overflow."
	if(blocks["complexity"] > blocks["max_complexity"])
		return "Complexity overflow."


	// Block 3. Wires.
	if(blocks["wires"])
		if(!islist(blocks["wires"]))
			return "Invalid wiring list."	// Damaged wires list

		for(var/w in blocks["wires"])
			var/list/wire = w

			if(!islist(wire) || wire.len != 2)
				return "Invalid wire data."

			var/datum/integrated_io/IO = SScircuit.get_pin_ref_list(wire[1], assembly_circuits)
			var/datum/integrated_io/IO2 = SScircuit.get_pin_ref_list(wire[2], assembly_circuits)
			if(!IO || !IO2)
				return "Invalid wire data."

			if(initial(IO.io_type) != initial(IO2.io_type))
				return "Wire type mismatch."

	return blocks


// Loads assembly (in form of list) into an object and returns it.
// No sanity checks are performed, save file is expected to be validated by validate_electronic_assembly
/datum/controller/subsystem/processing/circuit/proc/load_electronic_assembly(loc, list/blocks)

	// Block 1. Assembly.
	var/list/assembly_params = blocks["assembly"]
	var/atom/assembly_path = all_assemblies[assembly_params["type"]]
	var/atom/assembly_atom = new assembly_path(null)
	var/datum/component/integrated_electronic/assembly = assembly_atom.GetComponent(/datum/component/integrated_electronic)
	assembly.load(assembly_params)



	// Block 2. Circuits.
	for(var/circuit_params in blocks["components"])
		var/obj/item/integrated_circuit/circuit_path = all_circuits[circuit_params["type"]]
		var/obj/item/integrated_circuit/circuit = new circuit_path(assembly)
		assembly.add_circuit(circuit)
		circuit.load(circuit_params)


	// Block 3. Wires.
	if(blocks["wires"])
		for(var/w in blocks["wires"])
			var/list/wire = w
			var/datum/integrated_io/IO = assembly.get_pin_ref_list(wire[1])
			var/datum/integrated_io/IO2 = assembly.get_pin_ref_list(wire[2])
			IO.connect_pin(IO2)

	var/atom/movable/assembly_movable = assembly.parent
	if(istype(assembly_movable))
		assembly_movable.forceMove(loc)
	return assembly

