ADMIN_VERB(cinematic, "Cinematic", "Shows a cinematic.", R_FUN, VERB_CATEGORY_FUN)
	if(!SSticker.initialized)
		to_chat(user, span_warning("The game hasn't finished loading!"))
		return

	var/datum/cinematic/choice = tgui_input_list(user, "Chose a cinematic to play to everyone in the server.", "Choose Cinematic", sort_list(subtypesof(/datum/cinematic), GLOBAL_PROC_REF(cmp_typepaths_asc)))
	if(!choice || !ispath(choice, /datum/cinematic))
		return

	play_cinematic(choice, world)
