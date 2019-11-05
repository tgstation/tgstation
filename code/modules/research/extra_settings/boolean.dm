/datum/nanite_extra_setting/boolean
	setting_type = NESTYPE_BOOLEAN
	var/true_text
	var/false_text

/datum/nanite_extra_setting/boolean/New(initial, true_text, false_text)
	value = initial
	src.true_text = true_text
	src.false_text = false_text

/datum/nanite_extra_setting/boolean/set_value(value)
	if(isnull(value))
		value = !value
		return
	. = ..()

/datum/nanite_extra_setting/boolean/get_frontend_list(name)
	return list(list(
		"name" = name,
		"type" = setting_type,
		"value" = value,
		"true_text" = true_text,
		"false_text" = false_text
	))
