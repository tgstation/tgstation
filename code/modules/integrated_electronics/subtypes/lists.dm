//These circuits do things with lists, and use special list pins for stability.
/obj/item/integrated_circuit/list
	complexity = 1
	inputs = list(
	"input" = IC_PINTYPE_LIST
	)
	outputs = list("result" = IC_PINTYPE_STRING)
	activators = list("compute" = IC_PINTYPE_PULSE_IN, "on computed" = IC_PINTYPE_PULSE_OUT)
	category_text = "Lists"
	power_draw_per_use = 20

/obj/item/integrated_circuit/list/pick
	name = "pick circuit"
	desc = "This circuit will randomly 'pick' an element from a list that is inputted."
	extended_desc = "Will output null if the list is empty.  Input list is unmodified."
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/list/pick/do_work()
	var/result = null
	var/list/input_list = get_pin_data(IC_INPUT, 1) // List pins guarantee that there is a list inside, even if just an empty one.
	if(input_list.len)
		result = pick(input_list)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)


/obj/item/integrated_circuit/list/append
	name = "append circuit"
	desc = "This circuit will add an element to a list."
	extended_desc = "The new element will always be at the bottom of the list."
	inputs = list(
		"list to append" = IC_PINTYPE_LIST,
		"input" = IC_PINTYPE_ANY
	)
	outputs = list(
		"appended list" = IC_PINTYPE_LIST
	)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/list/append/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/list/output_list = list()
	var/new_entry = get_pin_data(IC_INPUT, 2)
	output_list = input_list.Copy()
	output_list.Add(new_entry)

	set_pin_data(IC_OUTPUT, 1, output_list)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/list/search
	name = "search circuit"
	desc = "This circuit will give index of desired element in the list."
	extended_desc = "Search will start at 1 position and will return first matching position."
	inputs = list(
		"list" = IC_PINTYPE_LIST,
		"item" = IC_PINTYPE_ANY
	)
	outputs = list(
		"index" = IC_PINTYPE_NUMBER
	)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/list/search/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/item = get_pin_data(IC_INPUT, 2)
	set_pin_data(IC_OUTPUT, 1, input_list.Find(item))
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/list/at
	name = "at circuit"
	desc = "This circuit will pick an element from a list by index."
	extended_desc = "If there is no element with such index, result will be null."
	inputs = list(
		"list" = IC_PINTYPE_LIST,
		"index" = IC_PINTYPE_NUMBER
	)
	outputs = list("item" = IC_PINTYPE_ANY)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/list/at/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/index = get_pin_data(IC_INPUT, 2)
	var/item = input_list[index]
	set_pin_data(IC_OUTPUT, 1, item)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/list/delete
	name = "delete circuit"
	desc = "This circuit will delete the element from a list by index."
	extended_desc = "If there is no element with such index, result list will be unchanged."
	inputs = list(
		"list" = IC_PINTYPE_LIST,
		"index" = IC_PINTYPE_NUMBER
	)
	outputs = list(
		"item" = IC_PINTYPE_LIST
	)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/list/delete/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/list/red_list = list()
	var/index = get_pin_data(IC_INPUT, 2)
	var/j = 0
	for(var/I in input_list)
		j = j + 1
		if(j != index)
			red_list.Add(I)
	set_pin_data(IC_OUTPUT, 1, red_list)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/list/write
	name = "write circuit"
	desc = "This circuit will write element in list with given index."
	extended_desc = "If there is no element with such index, it will give the same list, as before."
	inputs = list(
		"list" = IC_PINTYPE_LIST,
		"index" = IC_PINTYPE_NUMBER,
		"item" = IC_PINTYPE_ANY
	)
	outputs = list(
		"redacted list" = IC_PINTYPE_LIST
	)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/list/write/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/index = get_pin_data(IC_INPUT, 2)
	var/item = get_pin_data(IC_INPUT, 3)
	input_list[index] = item
	set_pin_data(IC_OUTPUT, 1, input_list)
	push_data()
	activate_pin(2)

obj/item/integrated_circuit/list/len
	name = "len circuit"
	desc = "This circuit will give lenght of the list."
	inputs = list(
		"list" = IC_PINTYPE_LIST,
		)
	outputs = list(
		"item" = IC_PINTYPE_NUMBER
	)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/list/len/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	set_pin_data(IC_OUTPUT, 1, input_list.len)
	push_data()
	activate_pin(2)


/obj/item/integrated_circuit/list/jointext
	name = "join text circuit"
	desc = "This circuit will add all elements of a list into one string, seperated by a character."
	extended_desc = "Default settings will encode the entire list into a string."
	inputs = list(
		"list to join" = IC_PINTYPE_LIST,//
		"delimiter" = IC_PINTYPE_CHAR,
		"start" = IC_PINTYPE_NUMBER,
		"end" = IC_PINTYPE_NUMBER
	)
	inputs_default = list(
		"2" = ",",
		"3" = 1,
		"4" = 0
	)
	outputs = list(
		"joined text" = IC_PINTYPE_STRING
	)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/list/jointext/do_work()
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