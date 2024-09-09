/**
 * Takes a json value and converts it to a specific output value type.
 */
/datum/value_guard

/// Takes a json list and extracts a single value.
/// Subtypes represent different conversions of that value.
/datum/value_guard

/// Takes a value read directly from json and verifies/converts as needed to a result
/datum/value_guard/proc/ReadJson(value) -> RESULT
	RESULT_ERR("NOT IMPLEMENTED")

/datum/value_guard/text/ReadJson(value)
	if(!istext(value))
		RESULT_ERR("Text value expected but got '[value]'")
	return RESULT_OK(value)

/datum/value_guard/number/ReadJson(value)
	var/newvalue = text2num(value)
	if(!isnum(newvalue))
		RESULT_ERR("Number expected but got [newvalue]")
	return RESULT_OK(newvalue)

/datum/value_guard/number_color_list/ReadJson(list/value)
	if(!istype(value))
		RESULT_ERR("Expected a list but got [value]")
	var/list/new_values = list()
	for(var/number_string in value)
		var/new_value = text2num(number_string)
		if(!isnum(new_value))
			if(!istext(number_string) || number_string[1] != "#")
				stack_trace("Expected list to only contain numbers or colors but got '[number_string]'")
				continue
			new_value = number_string
		new_values += new_value
	return RESULT_OK(new_values)

/datum/value_guard/color_matrix/ReadJson(list/value)
	if(!istype(value))
		RESULT_ERR("Expected a list but got [value]")
	if(length(value) > 5 || length(value) < 4)
		RESULT_ERR("Color matrix must contain 4 or 5 rows")
	var/list/new_values = list()
	for(var/list/row in value)
		var/list/interpreted_row = list()
		if(!istype(row) || length(row) != 4)
			stack_trace("Expected list to contain further row lists with exactly 4 entries")
			interpreted_row = list(0, 0, 0, 0)
			continue
		for(var/number in row)
			if(!isnum(number))
				stack_trace("Each color matrix row must only contain numbers")
				interpreted_row += 0
			else
				interpreted_row += number
		new_values += interpreted_row
	return RESULT_OK(new_values)

/datum/value_guard/blend_mode
	var/static/list/blend_modes = list(
		"add" = ICON_ADD,
		"subtract" = ICON_SUBTRACT,
		"multiply" = ICON_MULTIPLY,
		"or" = ICON_OR,
		"overlay" = ICON_OVERLAY,
		"underlay" = ICON_UNDERLAY,
	)

/datum/value_guard/blend_mode/ReadJson(value)
	var/new_value = blend_modes[LOWER_TEXT(value)]
	if(isnull(new_value))
		RESULT_ERR("Blend mode expected but got '[value]'")
	return RESULT_OK(new_value)

/datum/value_guard/greyscale_config/ReadJson(value)
	var/newvalue = SSgreyscale.configurations[value]
	if(!newvalue)
		RESULT_ERR("Greyscale configuration type expected but got '[value]'")
	return RESULT_OK(newvalue)
