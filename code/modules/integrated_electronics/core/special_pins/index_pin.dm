// These pins can only contain integer numbers between 0 and IC_MAX_LIST_LENGTH. Null is allowed.
/datum/integrated_io/index
	name = "index pin"
	data = 1

/datum/integrated_io/index/ask_for_pin_data(mob/user)
	var/new_data = input("Please type in an index.","[src] index writing") as num
	if(isnum(new_data) && holder.check_interactivity(user))
		to_chat(user, "<span class='notice'>You input [new_data] into the pin.</span>")
		write_data_to_pin(new_data)

/datum/integrated_io/index/write_data_to_pin(new_data)
	if(isnull(new_data))
		new_data = 0

	if(isnum(new_data))
		data = Clamp(round(new_data), 0, IC_MAX_LIST_LENGTH)
		holder.on_data_written()

/datum/integrated_io/index/display_pin_type()
	return IC_FORMAT_INDEX
