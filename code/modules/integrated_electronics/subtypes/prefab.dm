// This is created when converting an assembly to a circuit. By default, it does nothing.
/obj/item/integrated_circuit/prefab
	name = "prefab circuit"
	desc = "A circuit which groups several circuits together, into a single compact one."
	complexity = 0 // will be the sum of the circuits it's made of
	size = 0 // will be the sum of the circuits it's made of
	var/list/circuit_components = list()

/obj/item/integrated_circuit/prefab/Initialize(mapload, obj/item/device/electronic_assembly/assembly)
	. = ..()
	if(!assembly)
		return
	for(var/i in assembly.assembly_components)
		var/obj/item/integrated_circuit/component = i
		component.forceMove(src)
		component.assembly = null
		circuit_components += component
		inputs += component.priority_inputs
		outputs += component.priority_outputs
		activators += component.priority_activators
		power_draw_per_use += component.power_draw_per_use
		complexity += component.complexity
		size += component.size
		action_flags |= component.action_flags

/obj/item/integrated_circuit/prefab/on_insert()
	for(var/i in circuit_components)
		var/obj/item/integrated_circuit/component = i
		component.assembly = assembly

/obj/item/integrated_circuit/prefab/on_remove()
	for(var/i in circuit_components)
		var/obj/item/integrated_circuit/component = i
		component.assembly = null

/obj/item/integrated_circuit/prefab/save() // Special json code to handle this
	var/list/component_params = ..() //name and type
	component_params["circuits"] = list()
	component_params["prioritized_io"] = list()
	var/list/priority_io = list()
	var/list/wires = list()
	var/list/saved_wires = list()
	for(var/i in circuit_components)
		var/obj/item/integrated_circuit/component = i
		component_params["circuits"] += list(component.save())

		var/list/all_pins = component.inputs + component.outputs + component.activators // wiring connections
		var/list/all_priority_pins = component.priority_inputs + component.priority_outputs + component.priority_activators //priority i/os

		for(var/p in all_pins)
			var/datum/integrated_io/pin = p
			var/list/params = pin.get_pin_parameters(circuit_components)
			var/text_params = params.Join()
			if(p in all_priority_pins)
				priority_io.Add(list(params)) // saves the i/o as a priority pin
			for(var/p2 in pin.linked)
				var/datum/integrated_io/pin2 = p2
				var/list/params2 = pin2.get_pin_parameters(circuit_components)
				var/text_params2 = params2.Join()
				// Check if we already saved an opposite version of this wire
				// (do not save the same wire twice)
				if((text_params2 + "=" + text_params) in saved_wires)
					continue
				// If not, add a wire "hash" for future checks and save it
				saved_wires.Add(text_params + "=" + text_params2)
				wires.Add(list(list(params, params2)))

	if(priority_io.len)
		component_params["prioritized_io"] = priority_io
	if(wires.len)
		component_params["wires"] = wires
	return component_params


/obj/item/integrated_circuit/prefab/load(list/component_params)
	for(var/i in component_params["circuits"])
		var/list/circuit = i
		var/obj/item/integrated_circuit/component_path = SScircuit.all_components[circuit["type"]]
		var/obj/item/integrated_circuit/component = new component_path(src)
		component.load(component_params)
		circuit_components += component
		power_draw_per_use += component.power_draw_per_use
		complexity += component.complexity
		size += component.size
		action_flags |= component.action_flags
	if(component_params["prioritized_io"])
		for(var/p in component_params["prioritized_io"])
			to_chat(world, "[assembly]")
			var/datum/integrated_io/IO = assembly.get_pin_ref_list(p,circuit_components)
			switch(IO.pin_type)
				if(IC_INPUT)
					inputs |= IO
				if(IC_OUTPUT)
					outputs |= IO
				if(IC_ACTIVATOR)
					activators |= IO
	if(component_params["wires"])
		for(var/w in component_params["wires"])
			var/list/wire = w
			var/datum/integrated_io/IO = assembly.get_pin_ref_list(wire[1],circuit_components)
			var/datum/integrated_io/IO2 = assembly.get_pin_ref_list(wire[2],circuit_components)
			IO.connect_pin(IO2)
	..()

/obj/item/integrated_circuit/prefab/verify_save(list/component_params) // kind of a copypasta, with some checks removed since prefabs have no pins when created
	var/init_name = initial(name)
	// Validate name
	if(component_params["name"] && !reject_bad_name(component_params["name"], TRUE))
		return "Bad component name at [init_name]."

	// Validate input values
	if(component_params["inputs"])
		var/list/loaded_inputs = component_params["inputs"]
		if(!islist(loaded_inputs))
			return "Malformed input values list at [init_name]."

		var/inputs_amt = length(component_params["prioritized_io"])
		to_chat(world, "[length(loaded_inputs)]")
		to_chat(world, "[inputs_amt]")
		// Too many inputs? Inputs for input-less component? This is not good.
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
			if(!isnum(input_id) || input_id % 1 || input_id < 1)
				return "Invalid input index at [init_name]."

/obj/item/integrated_circuit/prefab/on_attack_self(mob/user)
	for(var/i in circuit_components)
		var/obj/item/integrated_circuit/circuit = i
		circuit.on_attack_self(user) // this won't ask you which inner circuit to trigger, it'll trigger them all.

/obj/item/integrated_circuit/prefab/interact(mob/user, HTML)
	HTML += "<table border='1' style='undefined;table-layout: fixed; width: 80%'>"
	HTML += "<a href='?src=[REF(src)];prefab=1'>\[Check internal components\]</a><br></table>"
	..(user, HTML)

/obj/item/integrated_circuit/prefab/Topic(href, href_list)
	if(..())
		return TRUE
	if(href_list["prefab"])
		var/obj/item/integrated_circuit/circuitToView = input("Select a prefab component", "Prefab") as null|anything in circuit_components
		if(circuitToView)
			circuitToView.interact(usr)

// all the procs like do_work, on_data_written etc should be automatically called since the pins are owned by the circuit themselves.