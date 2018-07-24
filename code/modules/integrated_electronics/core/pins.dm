/*
	Pins both hold data for circuits, as well move data between them.  Some also cause circuits to do their function.  DATA_CHANNEL pins are the data holding/moving kind,
where as PULSE_CHANNEL causes circuits to work() when their pulse hits them.


A visualization of how pins work is below.  Imagine the below image involves an addition circuit.
When the bottom pin, the activator, receives a pulse, all the numbers on the left (input) get added, and the answer goes on the right side (output).

Inputs      Outputs

A [2]\      /[8] result
B [1]-\|++|/
C [4]-/|++|
D [1]/  ||
        ||
     Activator



*/
/datum/integrated_io
	var/name = "input/output"
	var/obj/item/integrated_circuit/holder
	var/datum/weakref/data  // This is a weakref, to reduce typecasts.  Note that oftentimes numbers and text may also occupy this.
	var/list/linked = list()
	var/io_type = DATA_CHANNEL
	var/pin_type			// IC_INPUT, IC_OUTPUT, IC_ACTIVATOR - used in saving assembly wiring
	var/ord

/datum/integrated_io/New(loc, _name, _data, _pin_type,_ord)
	name = _name
	if(_data)
		data = _data
	if(_pin_type)
		pin_type = _pin_type
	if(_ord)
		ord = _ord

	holder = loc

	if(!istype(holder))
		message_admins("ERROR: An integrated_io ([name]) spawned without a valid holder!  This is a bug.")

/datum/integrated_io/Destroy()
	disconnect_all()
	data = null
	holder = null
	return ..()

/datum/integrated_io/proc/data_as_type(var/as_type)
	if(!isweakref(data))
		return
	var/datum/weakref/w = data
	var/output = w.resolve()
	return istype(output, as_type) ? output : null

/datum/integrated_io/proc/display_data(var/input)
	if(isnull(input))
		return "(null)" // Empty data means nothing to show.

	if(istext(input))
		return "(\"[input]\")" // Wraps the 'string' in escaped quotes, so that people know it's a 'string'.

	if(islist(input))
		var/list/my_list = input
		var/result = "list\[[my_list.len]\]("
		if(my_list.len)
			result += "<br>"
			var/pos = 0
			for(var/line in my_list)
				result += "[display_data(line)]"
				pos++
				if(pos != my_list.len)
					result += ",<br>"
			result += "<br>"
		result += ")"
		return result

	if(isweakref(input))
		var/datum/weakref/w = input
		var/atom/A = w.resolve()
		return A ? "([A.name] \[Ref\])" : "(null)" // For refs, we want just the name displayed.

	return "([input])" // Nothing special needed for numbers or other stuff.

/datum/integrated_io/activate/display_data()
	return "(\[pulse\])"

/datum/integrated_io/proc/display_pin_type()
	return IC_FORMAT_ANY

/datum/integrated_io/activate/display_pin_type()
	return IC_FORMAT_PULSE

/datum/integrated_io/proc/scramble()
	if(isnull(data))
		return
	if(isnum(data))
		write_data_to_pin(rand(-10000, 10000))
	if(istext(data))
		write_data_to_pin("ERROR")
	push_data()

/datum/integrated_io/activate/scramble()
	push_data()

/datum/integrated_io/proc/handle_wire(datum/integrated_io/linked_pin, obj/item/tool, action, mob/living/user)
	if(istype(tool, /obj/item/multitool))
		var/obj/item/multitool/multitool = tool
		switch(action)
			if("wire")
				multitool.wire(src, user)
				return TRUE
			if("unwire")
				if(linked_pin)
					multitool.unwire(src, linked_pin, user)
					return TRUE
			if("data")
				ask_for_pin_data(user)
				return TRUE

	else if(istype(tool, /obj/item/integrated_electronics/wirer))
		var/obj/item/integrated_electronics/wirer/wirer = tool
		if(linked_pin)
			wirer.wire(linked_pin, user)
		else
			wirer.wire(src, user)

	else if(istype(tool, /obj/item/integrated_electronics/debugger))
		var/obj/item/integrated_electronics/debugger/debugger = tool
		debugger.write_data(src, user)
		return TRUE

	return FALSE

/datum/integrated_io/proc/write_data_to_pin(new_data)
	if(isnull(new_data) || isnum(new_data) || istext(new_data) || isweakref(new_data))
		data = new_data
		holder.on_data_written()
	else if(islist(new_data))
		var/list/new_list = new_data
		data = new_list.Copy(max(1,new_list.len - IC_MAX_LIST_LENGTH+1),0)
		holder.on_data_written()

/datum/integrated_io/proc/push_data()
	for(var/k in 1 to linked.len)
		var/datum/integrated_io/io = linked[k]
		io.write_data_to_pin(data)

/datum/integrated_io/activate/push_data()
	for(var/k in 1 to linked.len)
		var/datum/integrated_io/io = linked[k]
		io.holder.check_then_do_work(io.ord)

/datum/integrated_io/proc/pull_data()
	for(var/k in 1 to linked.len)
		var/datum/integrated_io/io = linked[k]
		write_data_to_pin(io.data)

/datum/integrated_io/proc/get_linked_to_desc()
	if(linked.len)
		return "the [english_list(linked)]"
	return "nothing"


/datum/integrated_io/proc/connect_pin(datum/integrated_io/pin)
	pin.linked |= src
	linked |= pin

// Iterates over every linked pin and disconnects them.
/datum/integrated_io/proc/disconnect_all()
	for(var/pin in linked)
		disconnect_pin(pin)

/datum/integrated_io/proc/disconnect_pin(datum/integrated_io/pin)
	pin.linked.Remove(src)
	linked.Remove(pin)


/datum/integrated_io/proc/ask_for_data_type(mob/user, var/default, var/list/allowed_data_types = list("string","number","null"))
	var/type_to_use = input("Please choose a type to use.","[src] type setting") as null|anything in allowed_data_types
	if(!holder.check_interactivity(user))
		return

	var/new_data = null
	switch(type_to_use)
		if("string")
			new_data = stripped_multiline_input(user, "Now type in a string.","[src] string writing", istext(default) ? default : null, no_trim = TRUE)
			if(istext(new_data) && holder.check_interactivity(user) )
				to_chat(user, "<span class='notice'>You input "+new_data+" into the pin.</span>")
				return new_data
		if("number")
			new_data = input("Now type in a number.","[src] number writing", isnum(default) ? default : null) as null|num
			if(isnum(new_data) && holder.check_interactivity(user) )
				to_chat(user, "<span class='notice'>You input [new_data] into the pin.</span>")
				return new_data
		if("null")
			if(holder.check_interactivity(user))
				to_chat(user, "<span class='notice'>You clear the pin's memory.</span>")
				return new_data

// Basically a null check
/datum/integrated_io/proc/is_valid()
	return !isnull(data)

// This proc asks for the data to write, then writes it.
/datum/integrated_io/proc/ask_for_pin_data(mob/user)
	var/new_data = ask_for_data_type(user)
	write_data_to_pin(new_data)

/datum/integrated_io/activate/ask_for_pin_data(mob/user) // This just pulses the pin.
	holder.investigate_log(" was manually pulsed by [key_name(user)].", INVESTIGATE_CIRCUIT)
	holder.check_then_do_work(ord,ignore_power = TRUE)
	to_chat(user, "<span class='notice'>You pulse \the [holder]'s [src] pin.</span>")

/datum/integrated_io/activate
	name = "activation pin"
	io_type = PULSE_CHANNEL

/datum/integrated_io/activate/out // All this does is just make the UI say 'out' instead of 'in'
	data = 1
