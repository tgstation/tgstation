/client/proc/cinematic()
	set name = "Cinematic"
	set category = "Admin.Fun"
	set desc = "Shows a cinematic." // Intended for testing but I thought it might be nice for events on the rare occasion Feel free to comment it out if it's not wanted.
	set hidden = TRUE

	if(!SSticker)
		return

	var/datum/cinematic/choice = tgui_input_list(usr, "Chose a cinematic to play to everyone in the server.", "Choose Cinematic", sort_list(subtypesof(/datum/cinematic), /proc/cmp_typepaths_asc))
	if(!choice || !ispath(choice, /datum/cinematic))
		return

	play_cinematic(choice, world)
