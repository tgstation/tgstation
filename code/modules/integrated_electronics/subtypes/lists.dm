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
	if(CIRCUIT_LIST_VALID_VALUE(new_entry))
		output_list.Add(new_entry)
	if(CIRCUIT_LIST_VALID_KEY(new_entry) && CIRCUIT_LIST_VALID_VALUE(value))
		output_list[new_entry] = value

	set_pin_data(IC_OUTPUT, 1, output_list)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/lists/insert
	name = "insert circuit"
	desc = "This circuit will insert an element into a list at a certain index, pushing the existing element and therefore the rest of the list down."
	extended_desc = "If the index is one plus the list's length, the element will be appended instead. If the associative value is set, that will be attempted to be set if the element is a valid key and the value is a valid associative value."
	inputs = list(
		"list to insert into" = IC_PINTYPE_LIST,
		"index" = IC_PINTYPE_INDEX,
		"element" = IC_PINTYPE_ANY,
		"associative value" = IC_PINTYPE_ANY
		)
	outputs = list(
		"inserted into" = IC_PINTYPE_LIST
		)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/lists/insert/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/index = get_pin_data(IC_INPUT, 2)
	var/element = get_pin_data(IC_INPUT, 3)
	var/value = get_pin_data(IC_INPUT, 4)
	if((index < 1) || (index > input_list.len + 1) || !CIRCUIT_LIST_VALID_VALUE(element))		//Invalid index
		return
	else if(index == input_list.len + 1)
		input_list.len++
	var/list/output_list = input_list.Copy()
	output_list.Insert(index, element)
	if(CIRCUIT_LIST_VALID_KEY(element) && CIRCUIT_LIST_VALID_VALUE(value))
		output_list[element] = value

	set_pin_data(IC_OUTPUT, 1, output_list)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/lists/cut
	name = "cut circuit"
	desc = "This circuit will cut the elements from a list from the starting (first element to cut out) to ending (index immediately following the last element to cut) index."
	extended_desc = "Lists begin with index 1. Start index will be clamped between 1 (first element in the list) to the last element in the list. End index will be clamped to 2 (following the first element in the list) and to one plus the last element in the list. Setting the end to 0 will cut the entire list, but why would you do that?"
	inputs = list(
		"list to cut" = IC_PINTYPE_LIST,
		"start" = IC_PINTYPE_NUMBER,
		"end" = IC_PINTYPE_NUMBER
		)
	outputs = list(
		"redacted list" = IC_PINTYPE_LIST
		)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/lists/cut/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/start = get_pin_data(IC_INPUT, 2)
	var/end = get_pin_data(IC_INPUT, 3)
	start = CLAMP(start, 1, input_list.len)
	if(end != 0)
		end = CLAMP(end, 2, input_list.len + 1)
		if(end == input_list.len + 1)
			end = 0
	var/list/output_list = input_list.Copy()
	output_list.Cut(start, end)
	
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
	complexity = 2
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


/obj/item/integrated_circuit/lists/filter
	name = "filter circuit"
	desc = "This circuit will search through a list for anything matching the desired element(s) and outputs two lists: \
	one containing just matching elements, and one with matching elements filtered out."
	extended_desc = "Sample accepts lists. If no match is found, original list is sent to output 1."
	inputs = list(
		"input list" = IC_PINTYPE_LIST,
		"sample" = IC_PINTYPE_ANY
		)
	outputs = list(
		"list filtered" = IC_PINTYPE_LIST,
		"list matched" = IC_PINTYPE_LIST
		)
	activators = list(
		"compute" = IC_PINTYPE_PULSE_IN,
		"on match" = IC_PINTYPE_PULSE_OUT,
		"on no match" = IC_PINTYPE_PULSE_OUT
		)
	complexity = 6
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/lists/filter/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/sample = get_pin_data(IC_INPUT, 2)
	var/list/sample_list = islist(sample) ? uniqueList(sample) : null
	var/list/output_list1 = input_list.Copy()
	var/list/output_list2 = list()
	var/list/output = list()

	for(var/input_item in input_list)
		if(sample_list)
			for(var/sample_item in sample_list)
				if(!isnull(sample_item))
					if(istext(input_item) && istext(sample_item) && findtext(input_item, sample_item))
						output += input_item
					if(istype(input_item, /atom) && istext(sample_item))
						var/atom/input_item_atom = input_item
						if(istext(sample_item) && findtext(input_item_atom.name, sample_item))
							output += input_item
				if(!istext(input_item))
					if(input_item == sample_item)
						output += input_item
		else
			if(!isnull(sample))
				if(istext(input_item) && istext(sample) && findtext(input_item, sample))
					output += input_item
					continue
				if(istype(input_item, /atom) && istext(sample))
					var/atom/input_itema = input_item
					if(findtext(input_itema.name, sample))
						output += input_item
			if(!istext(input_item))
				if(input_item == sample)
					output += input_item

	output_list1.Remove(output)
	output_list2.Add(output)
	set_pin_data(IC_OUTPUT, 1, output_list1)
	set_pin_data(IC_OUTPUT, 2, output_list2)
	push_data()

	output_list1 ~! input_list ? activate_pin(2) : activate_pin(3)

/obj/item/integrated_circuit/lists/listset
	name = "list set circuit"
	desc = "This circuit will remove any duplicate entries from a list."
	extended_desc = "If there are no duplicate entries, result list will be unchanged."
	inputs = list(
		"list" = IC_PINTYPE_LIST
		)
	outputs = list(
		"list filtered" = IC_PINTYPE_LIST
		)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/lists/listset/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	input_list = uniqueList(input_list)

	set_pin_data(IC_OUTPUT, 1, input_list)
	push_data()
	activate_pin(2)

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
		"on failure" = IC_PINTYPE_PULSE_OUT
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
	desc = "This circuit will remove an element from a list by the index or associative key."
	extended_desc = "If there is no element with such index or key, result list will be unchanged."
	inputs = list(
		"list" = IC_PINTYPE_LIST,
		"index" = IC_PINTYPE_ANY
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

	if(length(input_list))
		red_list = input_list.Copy()
		if(isnum(index))
			red_list.Cut(index, index+1)
		else if(CIRCUIT_LIST_VALID_KEY(index))
			red_list -= index
	set_pin_data(IC_OUTPUT, 1, red_list)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/lists/write
	name = "write circuit"
	desc = "This circuit will write an element to a list at the given index location. If the index is a string or a weak reference, the element will be associated to the index in an association write. If the associative value is set and the element is a string or a weak reference, it will try to associate the value with the element. Associations only work if the item written is a text string or weak reference."
	extended_desc = "If there is no element with such index, it will give the same list as before. Writing to an index one above the list's length will append it instead. Writing to index 0 will insert the item before the first entry in the list, pushing the list down."
	inputs = list(
		"list" = IC_PINTYPE_LIST,
		"index" = IC_PINTYPE_ANY,
		"element/key" = IC_PINTYPE_ANY,
		"associative value" = IC_PINTYPE_ANY
		)
	outputs = list(
		"redacted list" = IC_PINTYPE_LIST
		)
	activators = list(
		"compute" = IC_PINTYPE_PULSE_IN,
		"on success" = IC_PINTYPE_PULSE_OUT,
		"on failure" = IC_PINTYPE_PULSE_OUT
		)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/lists/write/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/index = get_pin_data(IC_INPUT, 2)
	var/element = get_pin_data(IC_INPUT, 3)
	var/assoc_value = get_pin_data(IC_INPUT, 4)
	
	if(isnum(index))
		// Check if index is valid
		if(index == input_list.len + 1)		//Append write
			input_list.len++
		
		else if(index > input_list.len)		//Out of bounds
			set_pin_data(IC_OUTPUT, 1, input_list)
			push_data()
			activate_pin(3)
			return

		if(CIRCUIT_LIST_VALID_VALUE(element))		//Write element to index
			var/list/red_list = input_list.Copy()			//crash proof
			red_list[index] = element
			if(CIRCUIT_LIST_VALID_KEY(element) && CIRCUIT_LIST_VALID_VALUE(assoc_value))		//Associate element with value
				red_list[element] = assoc_value
			set_pin_data(IC_OUTPUT, 1, red_list)
			push_data()
			activate_pin(2)
	
	else if(CIRCUIT_LIST_VALID_KEY(index) && CIRCUIT_LIST_VALID_VALUE(element))			//Association write
		var/list/red_list = input_list.Copy()
		red_list[index] = element
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
	desc = "This circuit will combine all the strings in a list output it as a string. If list is associative, will only read keys."
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
		if(CIRCUIT_LIST_VALID_VALUE(data))
			output_list += data
			if(CIRCUIT_LIST_VALID_KEY(data) && CIRCUIT_LIST_VALID_VALUE(value))
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
