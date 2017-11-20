//These circuits do things with lists, and use special list pins for stability.
/obj/item/integrated_circuit/lists
	complexity = 1
	inputs = list(
	"input" = IC_PINTYPE_LIST
	)
	outputs = list("result" = IC_PINTYPE_STRING)
	activators = list("compute" = IC_PINTYPE_PULSE_IN, "on computed" = IC_PINTYPE_PULSE_OUT)
	category_text = "Lists"
	power_draw_per_use = 20

/obj/item/integrated_circuit/lists/pick
	name = "pick circuit"
	desc = "This circuit will pick a random element from the input list, and output said element."
	extended_desc = "Will output null if the list is empty.  Input list is unmodified."
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/lists/pick/do_work()
	var/result = null
	var/list/input_list = get_pin_data(IC_INPUT, 1) // List pins guarantee that there is a list inside, even if just an empty one.
	if(input_list.len)
		result = pick(input_list)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)


/obj/item/integrated_circuit/lists/append
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

/obj/item/integrated_circuit/lists/append/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/list/output_list = list()
	var/new_entry = get_pin_data(IC_INPUT, 2)
	output_list = input_list.Copy()
	output_list.Add(new_entry)

	set_pin_data(IC_OUTPUT, 1, output_list)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/lists/search
	name = "search circuit"
	desc = "This circuit will get the index location of the desired element in a list."
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

/obj/item/integrated_circuit/lists/search/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/item = get_pin_data(IC_INPUT, 2)
	set_pin_data(IC_OUTPUT, 1, input_list.Find(item))
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/lists/at
	name = "at circuit"
	desc = "This circuit will pick an element from a list by the input index."
	extended_desc = "If there is no element with such index, result will be null."
	inputs = list(
		"list" = IC_PINTYPE_LIST,
		"index" = IC_PINTYPE_NUMBER
	)
	outputs = list("item" = IC_PINTYPE_ANY)
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/lists/at/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/index = get_pin_data(IC_INPUT, 2)
	var/item = input_list[index]
	set_pin_data(IC_OUTPUT, 1, item)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/lists/delete
	name = "delete circuit"
	desc = "This circuit will remove an element from a list by the index."
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

/obj/item/integrated_circuit/lists/delete/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/list/red_list = list()
	var/index = get_pin_data(IC_INPUT, 2)
	for(var/j in 1 to input_list.len)
		var/I = input_list[j]
		if(j != index)
			red_list.Add(I)
	set_pin_data(IC_OUTPUT, 1, red_list)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/lists/write
	name = "write circuit"
	desc = "This circuit will write an element to a list at the given index location."
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

/obj/item/integrated_circuit/lists/write/do_work()
	var/list/input_list = get_pin_data(IC_INPUT, 1)
	var/index = get_pin_data(IC_INPUT, 2)
	var/item = get_pin_data(IC_INPUT, 3)
	if(!islist(item))	
		var/list/red_list = input_list.Copy()			//crash proof
		red_list[index] = item
		set_pin_data(IC_OUTPUT, 1, red_list)
		push_data()
		activate_pin(2)


obj/item/integrated_circuit/lists/len
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


/obj/item/integrated_circuit/lists/jointext
	name = "join text circuit"
	desc = "This circuit will combine two lists into one and output it as a string."
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
