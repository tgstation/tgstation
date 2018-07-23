/obj/item/integrated_circuit/text
	name = "text thingy"
	desc = "Does text-processing related things."
	category_text = "Text"
	complexity = 1

// - Text Replacer - //
/obj/item/integrated_circuit/text/text_replacer
	name = "find-replace circuit"
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
		"on replaced" = IC_PINTYPE_PULSE_OUT,
		"on found" = IC_PINTYPE_PULSE_OUT,
		"on not found" = IC_PINTYPE_PULSE_OUT
	)
	outputs = list(
		"replaced string" = IC_PINTYPE_STRING,
		"found" = IC_PINTYPE_BOOLEAN,
		"position" = IC_PINTYPE_NUMBER
	)

/obj/item/integrated_circuit/text/text_replacer/do_work()
	var/pos=findtext(get_pin_data(IC_INPUT, 1),get_pin_data(IC_INPUT, 2))
	set_pin_data(IC_OUTPUT, 1,replacetext(get_pin_data(IC_INPUT, 1), get_pin_data(IC_INPUT, 2), get_pin_data(IC_INPUT, 3)))
	set_pin_data(IC_OUTPUT, 3, pos)
	if(pos != 0)
		set_pin_data(IC_OUTPUT, 2, 1)
		push_data()
		activate_pin(3)
	else
		set_pin_data(IC_OUTPUT, 2, 0)
		push_data()
		activate_pin(4)
	activate_pin(2)
