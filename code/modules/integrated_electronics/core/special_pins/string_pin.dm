// These pins can only contain text and null.
/datum/integrated_io/string
	name = "string pin"

/datum/integrated_io/string/ask_for_pin_data(mob/user)
	var/new_data = stripped_multiline_input(user, "Please type in a string.","[src] string writing", no_trim = TRUE)
	if(holder.check_interactivity(user) )
		to_chat(user, "<span class='notice'>You input [new_data ? "[new_data]" : "NULL"] into the pin.</span>")
		write_data_to_pin(new_data)

/datum/integrated_io/string/write_data_to_pin(var/new_data)
	if(isnull(new_data) || istext(new_data))
		data = new_data
		holder.on_data_written()

// This makes the text go "from this" to "#G&*!HD$%L"
/datum/integrated_io/string/scramble()
	if(!is_valid())
		return
	var/list/options = list("!","@","#","$","%","^","&","*","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
	var/new_data = ""
	for(var/i in 1 to length(data))
		new_data += pick(options)
	push_data()

/datum/integrated_io/string/display_pin_type()
	return IC_FORMAT_STRING
