/obj/item/integrated_circuit/proc/setup_io(list/io_list, io_type, list/io_default_list, pin_type)
	var/list/io_list_copy = io_list.Copy()
	io_list.Cut()
	for(var/i in 1 to io_list_copy.len)
		var/io_entry = io_list_copy[i]
		var/default_data = null
		var/io_type_override = null

		// Override the default data.
		if(length(io_default_list)) // List containing special pin types that need to be added.
			default_data = io_default_list["[i]"] // This is deliberately text because the index is a number in text form.

		// Override the pin type.
		if(io_list_copy[io_entry])
			io_type_override = io_list_copy[io_entry]

		if(io_type_override)
			io_list.Add(new io_type_override(src, io_entry, default_data, pin_type,i))
		else
			io_list.Add(new io_type(src, io_entry, default_data, pin_type,i))


/obj/item/integrated_circuit/proc/set_pin_data(pin_type, pin_number, datum/new_data)
	if(islist(new_data))
		for(var/i in 1 to length(new_data))
			if (istype(new_data) && !isweakref(new_data))
				new_data[i] = WEAKREF(new_data[i])
	if (istype(new_data) && !isweakref(new_data))
		new_data = WEAKREF(new_data)
	var/datum/integrated_io/pin = get_pin_ref(pin_type, pin_number)
	return pin.write_data_to_pin(new_data)

/obj/item/integrated_circuit/proc/get_pin_data(pin_type, pin_number)
	var/datum/integrated_io/pin = get_pin_ref(pin_type, pin_number)
	return pin.get_data()

/obj/item/integrated_circuit/proc/get_pin_data_as_type(pin_type, pin_number, as_type)
	var/datum/integrated_io/pin = get_pin_ref(pin_type, pin_number)
	return pin.data_as_type(as_type)

/obj/item/integrated_circuit/proc/activate_pin(pin_number)
	var/datum/integrated_io/activate/A = activators[pin_number]
	A.push_data()

/obj/item/integrated_circuit/proc/get_pin_ref(pin_type, pin_number)
	switch(pin_type)
		if(IC_INPUT)
			if(pin_number > inputs.len)
				return
			return inputs[pin_number]
		if(IC_OUTPUT)
			if(pin_number > outputs.len)
				return
			return outputs[pin_number]
		if(IC_ACTIVATOR)
			if(pin_number > activators.len)
				return
			return activators[pin_number]
	return

/datum/integrated_io/proc/get_data()
	if(islist(data))
		for(var/i in 1 to length(data))
			if(isweakref(data[i]))
				data[i] = data[i].resolve()
	if(isweakref(data))
		return data.resolve()
	return data


// Returns a list of parameters necessary to locate a pin in the assembly: component number, pin type and pin number
// Components list can be supplied from the outside, for use in savefiles
/datum/integrated_io/proc/get_pin_parameters(list/components)
	if(!holder)
		return

	if(!components)
		if(!holder.assembly)
			return
		components = holder.assembly.assembly_components

	var/component_number = components.Find(holder)

	var/list/pin_holder_list
	switch(pin_type)
		if(IC_INPUT)
			pin_holder_list = holder.inputs
		if(IC_OUTPUT)
			pin_holder_list = holder.outputs
		if(IC_ACTIVATOR)
			pin_holder_list = holder.activators
		else
			return

	var/pin_number = pin_holder_list.Find(src)

	return list(component_number, pin_type, pin_number)


// Locates a pin in the assembly when given component number, pin type and pin number
// Components list can be supplied from the outside, for use in savefiles
/obj/item/electronic_assembly/proc/get_pin_ref(component_number, pin_type, pin_number, list/components)
	if(!components)
		components = assembly_components

	if(component_number > components.len)
		return

	var/obj/item/integrated_circuit/component = components[component_number]
	return component.get_pin_ref(pin_type, pin_number)


// Same as get_pin_ref, but takes in a list of 3 parameters (same format as get_pin_parameters)
// and performs extra sanity checks on parameters list and index numbers
/obj/item/electronic_assembly/proc/get_pin_ref_list(list/parameters, list/components)
	if(!components)
		components = assembly_components

	if(!islist(parameters) || parameters.len != 3)
		return

	// Those are supposed to be list indexes, check them for sanity
	if(!isnum(parameters[1]) || parameters[1] % 1 || parameters[1] < 1)
		return

	if(!isnum(parameters[3]) || parameters[3] % 1 || parameters[3] < 1)
		return

	return get_pin_ref(parameters[1], parameters[2], parameters[3], components)




// Used to obfuscate object refs imported/exported as strings.
// Not very secure, but if someone still finds a way to abuse refs, they deserve it.
/proc/XorEncrypt(string, key)
	if(!string || !key ||!istext(string)||!istext(key))
		return
	var/r
	for(var/i = 1 to length(string))
		r += ascii2text(text2ascii(string,i) ^ text2ascii(key,(i-1)%length(string)+1))
	return r

