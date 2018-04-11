//These circuits do things with lists, and use special list pins for stability.
/obj/item/integrated_circuit/lists
	complexity = 1
	inputs = list(
		"input" = IC_PINTYPE_LIST
		)
	outputs = list(
		"result" = IC_PINTYPE_STRING
		)
	activators = list(
		"compute" = IC_PINTYPE_PULSE_IN,
		"on computed" = IC_PINTYPE_PULSE_OUT
		)
	category_text = "Lists"
	power_draw_per_use = 20
	cooldown_per_use = 10

/obj/item/integrated_circuit/lists/pick
	name = "pick circuit"
	desc = "This circuit will pick a random element from the input list, and output said element, as well as its index, and value if applicable for associative lists."
	extended_desc = "Input list is unmodified."
	icon_state = "addition"
	outputs = list(
		"result key" = IC_PINTYPE_ANY,
		"result value" = IC_PINTYPE_ANY,
		"result index" = IC_PINTYPE_NUMBER
		)
	activators = list(
		"compute" = IC_PINTYPE_PULSE_IN,
		"on success" = IC_PINTYPE_PULSE_OUT,
		"on failure" = IC_PINTYPE_PULSE_OUT,
		)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	cooldown_per_use = 1

/obj/item/integrated_circuit/lists/pick/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1) // List pins guarantee that there is a list inside, even if just an empty one.
	if(input_list.len)
		var/res = rand(1, input_list.len)
		set_pin_data(IC_OUTPUT, 1, input_list[res])
		set_pin_data(IC_OUTPUT, 2, input_list[input_list[res]])
		set_pin_data(IC_OUTPUT, 3, res)
		push_data()
		activate_pin(2)
	else
		activate_pin(3)


/obj/item/integrated_circuit/lists/append
	name = "append circuit"
	desc = "This circuit will add an element to a list. If input is a string and value is specified, will associate value with input."
	extended_desc = "The new element will always be at the bottom of the list."
	inputs = list(
		"list to append" = IC_PINTYPE_LIST,
		"input" = IC_PINTYPE_ANY,
		"value" = IC_PINTYPE_ANY
		)
	outputs = list(
		"appended list" = IC_PINTYPE_LIST
		)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/lists/append/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/list/output_list = list()
	var/new_entry = get_pin_data(IC_INPUT, 2)
	var/value = get_pin_data(IC_INPUT, 3)
	output_list = input_list.Copy()
	output_list.Add(new_entry)
	if(istext(new_entry) && value)
		output_list[new_entry] = value

	set_pin_data(IC_OUTPUT, 1, output_list)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/lists/search
	name = "search circuit"
	desc = "This circuit will get the index location, and if associative, the value of the desired element in a list."
	extended_desc = "Search will start at 1 position and will return first matching position."
	inputs = list(
		"list" = IC_PINTYPE_LIST,
		"item" = IC_PINTYPE_ANY
		)
	outputs = list(
		"index" = IC_PINTYPE_NUMBER,
		"value" = IC_PINTYPE_ANY
		)
	activators = list(
		"compute" = IC_PINTYPE_PULSE_IN,
		"on success" = IC_PINTYPE_PULSE_OUT,
		"on failure" = IC_PINTYPE_PULSE_OUT,
		)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	cooldown_per_use = 1

/obj/item/integrated_circuit/lists/search/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/output = input_list.Find(get_pin_data(IC_INPUT, 2))

	set_pin_data(IC_OUTPUT, 1, output)
	if(istext(output))
		set_pin_data(IC_OUTPUT, 2, input_list[output])
	else
		set_pin_data(IC_OUTPUT, 2, null)
	push_data()

	if(output)
		activate_pin(2)
	else
		activate_pin(3)


/obj/item/integrated_circuit/lists/at
	name = "at circuit"
	desc = "This circuit will pick an element from a list by the input index. Will also output value if item is associated with a value."
	extended_desc = "If there is no element with such index, result will be null."
	inputs = list(
		"list" = IC_PINTYPE_LIST,
		"index" = IC_PINTYPE_INDEX
		)
	outputs = list(
		"item" = IC_PINTYPE_ANY,
		"value" = IC_PINTYPE_ANY
		)
	activators = list(
		"compute" = IC_PINTYPE_PULSE_IN,
		"on success" = IC_PINTYPE_PULSE_OUT,
		"on failure" = IC_PINTYPE_PULSE_OUT,
		)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	cooldown_per_use = 1

/obj/item/integrated_circuit/lists/at/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/index = get_pin_data(IC_INPUT, 2)

	// Check if index is valid
	if(index > input_list.len)
		set_pin_data(IC_OUTPUT, 1, null)
		push_data()
		activate_pin(3)
		return

	var/key = input_list[index]
	set_pin_data(IC_OUTPUT, 1, key)
	if(istext(key))
		set_pin_data(IC_OUTPUT, 2, input_list[key])
	push_data()
	activate_pin(2)


/obj/item/integrated_circuit/lists/delete
	name = "delete circuit"
	desc = "This circuit will remove an element from a list by the index if specified, and an element from the list with the matching key if specified for associative lists."
	extended_desc = "If there is no element with such index, result list will be unchanged."
	inputs = list(
		"list" = IC_PINTYPE_LIST,
		"index" = IC_PINTYPE_INDEX,
		"key" = IC_PINTYPE_STRING
		)
	outputs = list(
		"item" = IC_PINTYPE_LIST
		)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/lists/delete/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/list/red_list = list()
	var/index = get_pin_data(IC_INPUT, 2)
	var/key = get_pin_data(IC_INPUT, 3)

	if(length(input_list))
		red_list = input_list.Copy()
		if(index)
			red_list.Cut(index, index+1)
		if(key)
			red_list -= key
	set_pin_data(IC_OUTPUT, 1, red_list)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/lists/write
	name = "write circuit"
	desc = "This circuit will write an element to a list at the given index location. If value is specified, it will attempt to set the value of the item written to the value. Associations only work if the itme written is a text string."
	extended_desc = "If there is no element with such index, it will give the same list as before."
	inputs = list(
		"list" = IC_PINTYPE_LIST,
		"index" = IC_PINTYPE_INDEX,
		"item" = IC_PINTYPE_ANY,
		"value" = IC_PINTYPE_ANY
		)
	outputs = list(
		"redacted list" = IC_PINTYPE_LIST
		)
	activators = list(
		"compute" = IC_PINTYPE_PULSE_IN,
		"on success" = IC_PINTYPE_PULSE_OUT,
		"on failure" = IC_PINTYPE_PULSE_OUT,
		)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/lists/write/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/index = get_pin_data(IC_INPUT, 2)
	var/item = get_pin_data(IC_INPUT, 3)
	var/value = get_pin_data(IC_INPUT, 4)

	// Check if index is valid
	if(index > input_list.len)
		set_pin_data(IC_OUTPUT, 1, input_list)
		push_data()
		activate_pin(3)
		return

	if(!islist(item))
		var/list/red_list = input_list.Copy()			//crash proof
		red_list[index] = item
		if(istext(item) && value)
			red_list[item] = value
		set_pin_data(IC_OUTPUT, 1, red_list)
		push_data()
		activate_pin(2)

/obj/item/integrated_circuit/lists/len
	name = "len circuit"
	desc = "This circuit will return the length of the list."
	inputs = list(
		"list" = IC_PINTYPE_LIST,
		)
	outputs = list(
		"item" = IC_PINTYPE_NUMBER
		)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/lists/len/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	set_pin_data(IC_OUTPUT, 1, input_list.len)
	push_data()
	activate_pin(2)
	cooldown_per_use = 1


/obj/item/integrated_circuit/lists/jointext
	name = "join text circuit"
	desc = "This circuit will combine two lists into one and output it as a string. If list is associative, will only read keys."
	extended_desc = "Default settings will encode the entire list into a string."
	icon_state = "join"
	inputs = list(
		"list to join" = IC_PINTYPE_LIST,//
		"delimiter" = IC_PINTYPE_STRING,
		"start" = IC_PINTYPE_INDEX,
		"end" = IC_PINTYPE_NUMBER
		)
	inputs_default = list(
		"2" = ", ",
		"4" = 0
		)
	outputs = list(
		"joined text" = IC_PINTYPE_STRING
		)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	cooldown_per_use = 1

/obj/item/integrated_circuit/lists/jointext/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/delimiter = get_pin_data(IC_INPUT, 2)
	var/start = get_pin_data(IC_INPUT, 3)
	var/end = get_pin_data(IC_INPUT, 4)

	var/result = null

	if(input_list.len && delimiter && !isnull(start) && !isnull(end))
		result = jointext(input_list, delimiter, start, end)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)


/obj/item/integrated_circuit/lists/constructor
	name = "large list constructor"
	desc = "This circuit will build a list out of sixteen input values. Supports list associations. Associations only work if the key is a string."
	icon_state = "constr8"
	inputs = list()
	outputs = list(
		"result" = IC_PINTYPE_LIST
		)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/number_of_pins = 16

/obj/item/integrated_circuit/lists/constructor/Initialize()
	for(var/i in 1 to number_of_pins)
		inputs["key [i]"] = IC_PINTYPE_ANY // This is just a string since pins don't get built until ..() is called.
	for(var/i in 1 to number_of_pins)
		inputs["value [i]"] = IC_PINTYPE_ANY
	complexity = number_of_pins / 2
	return ..()

/obj/item/integrated_circuit/lists/constructor/do_work()
	var/list/output_list = list()
	for(var/i in 1 to number_of_pins)
		var/data = get_pin_data(IC_INPUT, i)
		var/value = get_pin_data(IC_INPUT, i + number_of_pins)

		// No nested lists
		if(!islist(data))
			output_list += data
			if(istext(data) && value)
				output_list[data] = value
		else
			output_list += null

	set_pin_data(IC_OUTPUT, 1, output_list)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/lists/constructor/small
	name = "list constructor"
	desc = "This circuit will build a list out of four input values. Supports associative lists. List associations only work if the key is a string."
	icon_state = "constr"
	number_of_pins = 4

/obj/item/integrated_circuit/lists/constructor/medium
	name = "medium list constructor"
	desc = "This circuit will build a list out of eight input values. Supports associative lists. List associations only work if the key is a string."
	icon_state = "constr8"
	number_of_pins = 8

/obj/item/integrated_circuit/lists/deconstructor
	name = "large list deconstructor"
	desc = "This circuit will write first sixteen entries of input list, starting with index, into the output values. Supports associative lsits."
	icon_state = "deconstr8"
	inputs = list(
		"input" = IC_PINTYPE_LIST,
		"index" = IC_PINTYPE_INDEX
		)
	outputs = list()
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/number_of_pins = 16

/obj/item/integrated_circuit/lists/deconstructor/Initialize()
	for(var/i in 1 to number_of_pins)
		outputs["output key [i]"] = IC_PINTYPE_ANY // This is just a string since pins don't get built until ..() is called.
	for(var/i in 1 to number_of_pins)
		outputs["output value [i]"] = IC_PINTYPE_ANY
	complexity = number_of_pins / 2
	. = ..()

/obj/item/integrated_circuit/lists/deconstructor/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/start_index = get_pin_data(IC_INPUT, 2)

	for(var/i = 1 to number_of_pins)
		var/list_index = i + start_index - 1
		if(list_index > input_list.len)
			set_pin_data(IC_OUTPUT, i, null)
		else
			var/data = input_list[list_index]
			set_pin_data(IC_OUTPUT, i, data)
			set_pin_data(IC_OUTPUT, i + number_of_pins, input_list[data])

	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/lists/deconstructor/small
	name = "list deconstructor"
	desc = "This circuit will write first four entries of input list, starting with index, into the output values. Supports associative lists."
	icon_state = "deconstr"
	number_of_pins = 4

/obj/item/integrated_circuit/lists/deconstructor/medium
	name = "medium list deconstructor"
	desc = "This circuit will write first eight entries of input list, starting with index, into the output values. Supports associative lists."
	number_of_pins = 8

/obj/item/integrated_circuit/lists/json_encode
	name = "JSON encoder"
	desc = "This circuit encodes a list into JSON format. Supports associative lists. Object references must be encoded by a reference encoder first, otherwise they will not encode properly."
	inputs = list("list" = IC_PINTYPE_LIST)
	outputs = list("json" = IC_PINTYPE_STRING)
	spawn_flags = IC_SPAWN_DEFAULT | IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/lists/json_encode/do_work()
	pull_data()
	var/list/L = get_pin_data(IC_INPUT, 1)
	set_pin_data(IC_OUTPUT, 1, json_encode(L))
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/lists/json_decode
	name = "JSON decoder"
	desc = "This circuit decodes a JSON formatted string into a list. Supports associative lists."
	inputs = list("json" = IC_PINTYPE_STRING)
	outputs = list("list" = IC_PINTYPE_LIST)
	spawn_flags = IC_SPAWN_DEFAULT | IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/lists/json_decode/do_work()
	pull_data()
	var/json = get_pin_data(IC_INPUT, 1)
	json = html_decode(json)			//Circuits uses stripped_input when getting data from users, and that will mess this up.
	var/list/L = json_decode(json)
	if(islist(L))
		for(var/i in 1 to L.len)
			var/key = L[i]
			var/value = L[key]
			var/changed = FALSE
			if(islist(key))
				key = json_encode(key)
				L[i] = key
				changed = TRUE
			if(islist(value))
				value = json_encode(value)
				changed = TRUE
			if(changed)
				L[key] = value
		set_pin_data(IC_OUTPUT, 1, L)
	else
		set_pin_data(IC_OUTPUT, 1, list())
	push_data()
	activate_pin(2)
