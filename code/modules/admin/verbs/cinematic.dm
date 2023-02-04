ADMIN_VERB(fun, show_cinematic, "Shows a cinematic", R_FUN)
	if(!SSticker.initialized)
		to_chat(usr, span_warning("Wait for the game to finish loading!"))
		return

	var/datum/cinematic/choice = tgui_input_list(usr, "Chose a cinematic to play to everyone in the server.", "Choose Cinematic", sort_list(subtypesof(/datum/cinematic), GLOBAL_PROC_REF(cmp_typepaths_asc)))
	if(!choice || !ispath(choice, /datum/cinematic))
		return

	play_cinematic(choice, world)
