/obj/item/integrated_circuit/text
	name = "text thingy"
	desc = "Does text-processing related things."
	category_text = "Text"
	complexity = 1


/obj/item/integrated_circuit/text/lowercase
	name = "lowercase string converter"
	desc = "this circuit will cause a string to come out in all lowercase."
	icon_state = "lowercase"
	inputs = list("input" = IC_PINTYPE_STRING)
	outputs = list("output" = IC_PINTYPE_STRING)
	activators = list("to lowercase" = IC_PINTYPE_PULSE_IN, "on converted" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/text/lowercase/do_work()
	var/result = null
	pull_data()
	var/incoming = get_pin_data(IC_INPUT, 1)
	if(!isnull(incoming))
		result = lowertext(incoming)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/text/uppercase
	name = "uppercase string converter"
	desc = "THIS WILL CAUSE A STRING TO COME OUT IN ALL UPPERCASE."
	icon_state = "uppercase"
	inputs = list("input" = IC_PINTYPE_STRING)
	outputs = list("output" = IC_PINTYPE_STRING)
	activators = list("to uppercase" = IC_PINTYPE_PULSE_IN, "on converted" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/text/uppercase/do_work()
	var/result = null
	pull_data()
	var/incoming = get_pin_data(IC_INPUT, 1)
	if(!isnull(incoming))
		result = uppertext(incoming)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/text/concatenator
	name = "concatenator"
	desc = "This can join up to 8 strings together to get a string with a maximum of 512 characters."
	complexity = 4
	inputs = list()
	outputs = list("result" = IC_PINTYPE_STRING)
	activators = list("concatenate" = IC_PINTYPE_PULSE_IN, "on concatenated" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/number_of_pins = 8
	var/max_string_length = 512

/obj/item/integrated_circuit/text/concatenator/Initialize()
	for(var/i = 1 to number_of_pins)
		inputs["input [i]"] = IC_PINTYPE_STRING
	. = ..()

/obj/item/integrated_circuit/text/concatenator/do_work()
	var/result = null
	var/spamprotection
	for(var/k in 1 to inputs.len)
		var/I = get_pin_data(IC_INPUT, k)
		if(!isnull(I))
			if((result ? length(result) : 0) + length(I) > max_string_length)
				spamprotection = (result ? length(result) : 0) + length(I)
				break
			result = result + I

	if(spamprotection >= max_string_length*1.75 && assembly)
		if(assembly.fingerprintslast)
			var/mob/M = get_mob_by_key(assembly.fingerprintslast)
			var/more = ""
			if(M)
				more = "[ADMIN_LOOKUPFLW(M)] "
			message_admins("A concatenator circuit has greatly exceeded its [max_string_length] character limit with a total of [spamprotection] characters, and has been deleted. Assembly last touched by [more ? more : assembly.fingerprintslast].")
			investigate_log("A concatenator circuit has greatly exceeded its [max_string_length] character limit with a total of [spamprotection] characters, and has been deleted. Assembly last touched by [assembly.fingerprintslast].", INVESTIGATE_CIRCUIT)
		else
			message_admins("A concatenator circuit has greatly exceeded its [max_string_length] character limit with a total of [spamprotection] characters, and has been deleted. No associated key.")
			investigate_log("A concatenator circuit has greatly exceeded its [max_string_length] character limit with a total of [spamprotection] characters, and has been deleted. No associated key.", INVESTIGATE_CIRCUIT)
		qdel(assembly)
		return

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/text/concatenator/small
	name = "small concatenator"
	desc = "This can join up to 4 strings together to get a string with a maximum of 256 characters."
	complexity = 2
	number_of_pins = 4
	max_string_length = 256

/obj/item/integrated_circuit/text/concatenator/large
	name = "large concatenator"
	desc = "This can join up to 16 strings together to get a string with a maximum of 1024 characters."
	complexity = 6
	number_of_pins = 16
	max_string_length = 1024

/obj/item/integrated_circuit/text/separator
	name = "separator"
	desc = "This splits a single string into two at the relative split point."
	extended_desc = "This circuit splits a given string into two, based on the string and the index value. \
	The index splits the string <b>after</b> the given index, including spaces. So 'a person' with an index of '3' \
	will split into 'a p' and 'erson'."
	icon_state = "split"
	complexity = 4
	inputs = list(
		"string to split" = IC_PINTYPE_STRING,
		"index" = IC_PINTYPE_NUMBER,
		)
	outputs = list(
		"before split" = IC_PINTYPE_STRING,
		"after split" = IC_PINTYPE_STRING
		)
	activators = list("separate" = IC_PINTYPE_PULSE_IN, "on separated" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/text/separator/do_work()
	var/text = get_pin_data(IC_INPUT, 1)
	var/index = get_pin_data(IC_INPUT, 2)

	var/split = min(index+1, length(text))

	var/before_text = copytext(text, 1, split)
	var/after_text = copytext(text, split, 0)

	set_pin_data(IC_OUTPUT, 1, before_text)
	set_pin_data(IC_OUTPUT, 2, after_text)
	push_data()

	activate_pin(2)

/obj/item/integrated_circuit/text/indexer
	name = "indexer"
	desc = "This circuit takes a string and an index value, then returns the character found at in the string at the given index."
	extended_desc = "Make sure the index is not longer or shorter than the string length. If you don't, the circuit will return empty."
	icon_state = "split"
	complexity = 4
	inputs = list(
		"string to index" = IC_PINTYPE_STRING,
		"index" = IC_PINTYPE_NUMBER,
		)
	outputs = list(
		"found character" = IC_PINTYPE_STRING
		)
	activators = list("index" = IC_PINTYPE_PULSE_IN, "on indexed" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/text/indexer/do_work()
	var/strin = get_pin_data(IC_INPUT, 1)
	var/ind = get_pin_data(IC_INPUT, 2)
	if(ind > 0 && ind <= length(strin))
		set_pin_data(IC_OUTPUT, 1, strin[ind])
	else
		set_pin_data(IC_OUTPUT, 1, "")
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/text/findstring
	name = "find text"
	desc = "This outputs the position of the sample in the string, or returns 0."
	extended_desc = "The first pin is the string to be examined. The second pin is the sample to be found. \
	For example, inputting 'my wife has caught on fire' with 'has' as the sample will give you position 9. \
	This circuit isn't case sensitive, and it does not ignore spaces."
	complexity = 4
	inputs = list(
		"string" = IC_PINTYPE_STRING,
		"sample" = IC_PINTYPE_STRING,
		)
	outputs = list(
		"position" = IC_PINTYPE_NUMBER
		)
	activators = list("search" = IC_PINTYPE_PULSE_IN, "after search" = IC_PINTYPE_PULSE_OUT, "found" = IC_PINTYPE_PULSE_OUT, "not found" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH


/obj/item/integrated_circuit/text/findstring/do_work()
	var/position = findtext(get_pin_data(IC_INPUT, 1),get_pin_data(IC_INPUT, 2))

	set_pin_data(IC_OUTPUT, 1, position)
	push_data()

	activate_pin(2)
	if(position)
		activate_pin(3)
	else
		activate_pin(4)

/obj/item/integrated_circuit/text/stringlength
	name = "get length"
	desc = "This circuit will return the number of characters in a string."
	complexity = 1
	inputs = list(
		"string" = IC_PINTYPE_STRING
		)
	outputs = list(
		"length" = IC_PINTYPE_NUMBER
		)
	activators = list("get length" = IC_PINTYPE_PULSE_IN, "on acquisition" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/text/stringlength/do_work()
	set_pin_data(IC_OUTPUT, 1, length(get_pin_data(IC_INPUT, 1)))
	push_data()

	activate_pin(2)

/obj/item/integrated_circuit/text/exploders
	name = "string exploder"
	desc = "This splits a single string into a list of strings."
	extended_desc = "This circuit splits a given string into a list of strings based on the string and given delimiter. \
	For example, 'eat this burger' will be converted to list('eat','this','burger'). Leave the delimiter null to get a list \
	of every individual character."
	icon_state = "split"
	complexity = 4
	inputs = list(
		"string to split" = IC_PINTYPE_STRING,
		"delimiter" = IC_PINTYPE_STRING,
		)
	outputs = list(
		"list" = IC_PINTYPE_LIST
		)
	activators = list("separate" = IC_PINTYPE_PULSE_IN, "on separated" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/text/exploders/do_work()
	var/strin = get_pin_data(IC_INPUT, 1)
	var/delimiter = get_pin_data(IC_INPUT, 2)
	if(delimiter == null)
		set_pin_data(IC_OUTPUT, 1, string2charlist(strin))
	else
		set_pin_data(IC_OUTPUT, 1, splittext(strin, delimiter))
	push_data()

	activate_pin(2)


// - Text Replacer - //
/obj/item/integrated_circuit/text/text_replacer
	name = "replace circuit"
	desc = "Replaces all of one bit of text with another"
	extended_desc = "Takes a string(haystack) and puts out the string while having a certain word(needle) replaced with another."
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	inputs = list(
		"haystack" = IC_PINTYPE_STRING,
		"needle" = IC_PINTYPE_STRING,
		"replacement" = IC_PINTYPE_STRING
	)
	activators = list(
		"replace" = IC_PINTYPE_PULSE_IN,
		"on replaced" = IC_PINTYPE_PULSE_OUT
	)
	outputs = list(
		"replaced string" = IC_PINTYPE_STRING
	)

/obj/item/integrated_circuit/text/text_replacer/do_work()
	set_pin_data(IC_OUTPUT, 1,replacetext(get_pin_data(IC_INPUT, 1), get_pin_data(IC_INPUT, 2), get_pin_data(IC_INPUT, 3)))
	push_data()
	activate_pin(2)
