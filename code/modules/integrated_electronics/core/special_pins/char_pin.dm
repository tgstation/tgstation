// These pins can only contain a 1 character string or null.
/datum/integrated_io/char
	name = "char pin"

/datum/integrated_io/char/ask_for_pin_data(mob/user)
	var/new_data = stripped_input(user, "Please type in one character.","[src] char writing", no_trim = TRUE)
	if(holder.check_interactivity(user) )
		to_chat(user, "<span class='notice'>You input [new_data ? "new_data" : "NULL"] into the pin.</span>")
		write_data_to_pin(new_data)

/datum/integrated_io/char/write_data_to_pin(var/new_data)
	if(isnull(new_data) || istext(new_data))
		if(length(new_data) > 1)
			return
		data = new_data
		holder.on_data_written()

// This makes the text go from "A" to "%".
/datum/integrated_io/char/scramble()
	if(!is_valid())
		return
	var/list/options = list("!","@","#","$","%","^","&","*","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
	data = pick(options)
	push_data()

/datum/integrated_io/char/display_pin_type()
	return IC_FORMAT_CHAR
