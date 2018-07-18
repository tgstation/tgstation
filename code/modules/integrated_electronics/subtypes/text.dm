/obj/item/integrated_circuit/text
	name = "text thingy"
	desc = "Does text-processing related things."
	category_text = "Text"
	complexity = 1

// - Text Replacer - //
/obj/item/integrated_circuit/text/text_replacer
	name = "text replacing circuit"
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


// - Text Finder - //
/obj/item/integrated_circuit/text/text_finder
	name = "text finding circuit"
	desc = "Takes a string and returns whether or not a certain text is included in it."
	extended_desc = "Takes a string(haystack) and puts out the string while having a certain word(needle) replaced with another."
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	inputs = list(
		"haystack" = IC_PINTYPE_STRING,
		"needle" = IC_PINTYPE_STRING
	)
	activators = list(
		"find" = IC_PINTYPE_PULSE_IN,
		"push ref" = IC_PINTYPE_PULSE_OUT,
		"on found" = IC_PINTYPE_PULSE_OUT,
		"on not found" = IC_PINTYPE_PULSE_OUT
	)
	outputs = list(
		"found" = IC_PINTYPE_BOOLEAN,
		"position" = IC_PINTYPE_NUMBER
	)

/obj/item/integrated_circuit/text/text_finder/do_work()
	var/pos=findtext(get_pin_data(IC_INPUT, 1),get_pin_data(IC_INPUT, 2))
	set_pin_data(IC_OUTPUT, 2, pos)
	if(pos != 0)
		set_pin_data(IC_OUTPUT, 1, 1)
		push_data()
		activate_pin(3)
	else
		set_pin_data(IC_OUTPUT, 1, 0)
		push_data()
		activate_pin(4)
	activate_pin(2)

// - Regex Find - //
/obj/item/integrated_circuit/text/regex_finder
	name = "regular expression finding circuit"
	desc = "Takes a certain pattern and checks if it is in the string, where and what exactly the string containing the pattern is."
	extended_desc = "Takes a string(haystack) and finds a certain regular expression. This gives out the exact text and its position."
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	inputs = list(
		"haystack" = IC_PINTYPE_STRING,
		"regex" = IC_PINTYPE_STRING
	)
	activators = list(
		"find" = IC_PINTYPE_PULSE_IN,
		"push ref" = IC_PINTYPE_PULSE_OUT,
		"on found" = IC_PINTYPE_PULSE_OUT,
		"on not found" = IC_PINTYPE_PULSE_OUT
	)
	outputs = list(
		"found" = IC_PINTYPE_BOOLEAN,
		"position" = IC_PINTYPE_NUMBER,
		"text" = IC_PINTYPE_STRING,
		"group" = IC_PINTYPE_LIST
	)

/obj/item/integrated_circuit/text/regex_finder/do_work()
	var/regex/needle=regex(get_pin_data(IC_INPUT, 2))
	needle.Find(get_pin_data(IC_INPUT, 1))

	set_pin_data(IC_OUTPUT, 2, needle.index)
	set_pin_data(IC_OUTPUT, 3, needle.match)
	set_pin_data(IC_OUTPUT, 4, needle.group)
	if(needle.index != 0)
		set_pin_data(IC_OUTPUT, 1, 1)
		push_data()
		activate_pin(3)
	else
		set_pin_data(IC_OUTPUT, 1, 0)
		push_data()
		activate_pin(4)
	activate_pin(2)

// - Regex Replacer - //
/obj/item/integrated_circuit/text/regex_replacer
	name = "regular expression replacing circuit"
	desc = "Takes a certain pattern and checks if it is in the string and where."
	extended_desc = "Takes a string(haystack) and finds a certain regular expression. This gives out the string with replaced regular expression."
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

/obj/item/integrated_circuit/text/regex_replacer/do_work()
	var/regex/needle=regex(get_pin_data(IC_INPUT, 2))
	set_pin_data(IC_OUTPUT, 1,needle.Replace(get_pin_data(IC_INPUT, 1),get_pin_data(IC_INPUT, 3)))
	push_data()
	activate_pin(2)
