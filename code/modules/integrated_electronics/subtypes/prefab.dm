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
		power_draw_idle += component.power_draw_idle
		complexity += component.complexity
		size += component.size
		action_flags |= component.action_flags
		materials[MAT_METAL] += component.materials[MAT_METAL]

/obj/item/integrated_circuit/prefab/on_insert()
	for(var/i in circuit_components)
		var/obj/item/integrated_circuit/component = i
		component.assembly = assembly

/obj/item/integrated_circuit/prefab/on_remove()
	for(var/i in circuit_components)
		var/obj/item/integrated_circuit/component = i
		component.assembly = null

/obj/item/integrated_circuit/prefab/save() // Special json code to handle this
	var/list/component_params = list()
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
	component_params += ..() //name, type and input values
	return component_params


/obj/item/integrated_circuit/prefab/load(list/component_params)
	for(var/i in component_params["circuits"])
		var/list/circuit = i
		var/obj/item/integrated_circuit/component_path = SScircuit.all_components[circuit["type"]]
		var/obj/item/integrated_circuit/component = new component_path(src)
		component.load(circuit)
		circuit_components += component
		power_draw_per_use += component.power_draw_per_use
		complexity += component.complexity
		size += component.size
		action_flags |= component.action_flags
	if(component_params["prioritized_io"])
		for(var/p in component_params["prioritized_io"])
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

/obj/item/integrated_circuit/prefab/verify_save(list/component_params, list/json_program)
	..()
	for(var/C in component_params["circuits"])
		var/list/circuit = C
		var/component_path = SScircuit.all_components[circuit["type"]]
		var/obj/item/integrated_circuit/component = SScircuit.cached_components[component_path]
		if(!component)
			return "Invalid internal prefab component type."
		json_program["complexity"] += component.complexity
		json_program["used_space"] += component.size
		json_program["metal_cost"] += component.materials[MAT_METAL]

/obj/item/integrated_circuit/prefab/external_examine(mob/user)
	..()
	for(var/i in circuit_components)
		var/obj/item/integrated_circuit/circuit = i
		circuit.any_examine(user)

/obj/item/integrated_circuit/prefab/attackby_react(atom/movable/A,mob/user)
	..()
	for(var/i in circuit_components)
		var/obj/item/integrated_circuit/circuit = i
		circuit.attackby_react(A,user)

/obj/item/integrated_circuit/prefab/sense(atom/A,mob/user,prox)
	..()
	for(var/i in circuit_components)
		var/obj/item/integrated_circuit/circuit = i
		circuit.sense(A,user,prox)

/obj/item/integrated_circuit/prefab/make_energy()
	..()
	for(var/i in circuit_components)
		var/obj/item/integrated_circuit/circuit = i
		circuit.make_energy()

/obj/item/integrated_circuit/prefab/special_input(mob/user, list/available_inputs, list/input_selection)
	..()
	. = TRUE // to not add the prefab itself to the
	for(var/c in circuit_components)
		var/obj/item/integrated_circuit/circuit = c
		if(circuit.can_be_asked_input)
			available_inputs.Add(circuit)
			var/i = 0
			for(var/obj/item/integrated_circuit/s in available_inputs)
				if(s.name == circuit.name && s.displayed_name == circuit.displayed_name && s != circuit)
					i++
			var/disp_name= "[circuit.displayed_name] \[[circuit]\]"
			if(i)
				disp_name += " ([i+1])"
			disp_name += "(in [displayed_name])"
			input_selection.Add(disp_name)

/obj/item/integrated_circuit/prefab/interact(mob/user, HTML)
	HTML += "<table border='1' style='undefined;table-layout: fixed; width: 80%'><div align='center'>"
	HTML += "<a href='?src=[REF(src)];prefab=1'>\[Check internal components\]</a><br></div></table>"
	..(user, HTML)

/obj/item/integrated_circuit/prefab/Topic(href, href_list)
	if(..())
		return TRUE
	if(href_list["prefab"])
		var/list/inputList = list()
		for(var/i in 1 to circuit_components.len) // all this shit is to avoid input() not displaying items with the same name
			inputList["([i]) [circuit_components[i]]"] = circuit_components[i]
		var/circuitToView = input("Select a prefab component", "Prefab") as null|anything in inputList
		if(circuitToView && (circuitToView in inputList))
			var/obj/item/integrated_circuit/C = inputList[circuitToView]
			if(C)
				C.interact(usr)

// all the procs like do_work, on_data_written etc should be automatically called since the pins are owned by the circuit themselves.