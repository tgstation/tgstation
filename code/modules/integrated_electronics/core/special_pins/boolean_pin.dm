// These pins only contain 0 or 1.  Null is not allowed.
/datum/integrated_io/boolean
	name = "boolean pin"
	data = FALSE

/datum/integrated_io/boolean/ask_for_pin_data(mob/user) // 'Ask' is a bit misleading, acts more like a toggle.
	var/new_data = !data
	write_data_to_pin(new_data)

/datum/integrated_io/boolean/write_data_to_pin(var/new_data)
	if(new_data == FALSE || new_data == TRUE)
		data = new_data
		holder.on_data_written()

/datum/integrated_io/boolean/scramble()
	write_data_to_pin(rand(FALSE,TRUE))
	push_data()

/datum/integrated_io/boolean/display_pin_type()
	return IC_FORMAT_BOOLEAN

/datum/integrated_io/boolean/display_data(var/input)
	if(data == TRUE)
		return "(True)"
	return "(False)"