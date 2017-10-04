/datum/language_menu
	var/datum/language_holder/language_holder

/datum/language_menu/New(language_holder)
	src.language_holder = language_holder

/datum/language_menu/Destroy()
	language_holder = null
	. = ..()

/datum/language_menu/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.language_menu_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "language_menu", "Language Menu", 700, 800, master_ui, state)
		ui.open()

/datum/language_menu/ui_data(mob/user)
	var/list/data = list()

	var/atom/movable/AM = language_holder.get_atom()
	if(isliving(AM))
		data["is_living"] = TRUE
	else
		data["is_living"] = FALSE

	data["languages"] = list()
	for(var/ld in GLOB.all_languages)
		var/result = language_holder.has_language(ld)
		if(!result)
			continue
		var/shadow = result == LANGUAGE_SHADOWED
		var/datum/language/LD = ld
		var/list/L = list()

		L["name"] = initial(LD.name)
		L["desc"] = initial(LD.desc)
		L["key"] = initial(LD.key)
		L["is_default"] = (LD == language_holder.selected_default_language)
		L["shadow"] = shadow
		if(AM)
			L["can_speak"] = AM.can_speak_in_language(LD)

		data["languages"] += list(L)

	if(check_rights_for(user.client, R_ADMIN) || isobserver(AM))
		data["admin_mode"] = TRUE
		data["omnitongue"] = language_holder.omnitongue

		data["unknown_languages"] = list()
		for(var/ld in GLOB.all_languages)
			if(language_holder.has_language(ld))
				continue
			var/datum/language/LD = ld
			var/list/L = list()

			L["name"] = initial(LD.name)
			L["desc"] = initial(LD.desc)
			L["key"] = initial(LD.key)

			data["unknown_languages"] += list(L)
	return data

/datum/language_menu/ui_act(action, params)
	if(..())
		return
	var/mob/user = usr
	var/atom/movable/AM = language_holder.get_atom()

	var/language_name = params["language_name"]
	var/datum/language/language_datum
	for(var/ld in GLOB.all_languages)
		var/datum/language/LD = ld
		if(language_name == initial(LD.name))
			language_datum = LD
	var/is_admin = check_rights_for(user.client, R_ADMIN)

	switch(action)
		if("select_default")
			if(language_datum && AM.can_speak_in_language(language_datum))
				language_holder.selected_default_language = language_datum
				. = TRUE
		if("grant_language")
			if((is_admin || isobserver(AM)) && language_datum)
				language_holder.grant_language(language_datum)
				if(is_admin)
					message_admins("[key_name_admin(user)] granted the [language_name] language to [key_name_admin(AM)].")
					log_admin("[key_name(user)] granted the language [language_name] to [key_name(AM)].")
				. = TRUE
		if("remove_language")
			if((is_admin || isobserver(AM)) && language_datum)
				language_holder.remove_language(language_datum)
				if(is_admin)
					message_admins("[key_name_admin(user)] removed the [language_name] language to [key_name_admin(AM)].")
					log_admin("[key_name(user)] removed the language [language_name] to [key_name(AM)].")
				. = TRUE
		if("toggle_omnitongue")
			if(is_admin || isobserver(AM))
				language_holder.omnitongue = !language_holder.omnitongue
				if(is_admin)
					message_admins("[key_name_admin(user)] [language_holder.omnitongue ? "enabled" : "disabled"] the ability to speak all languages (that they know) of [key_name_admin(AM)].")
					log_admin("[key_name(user)] [language_holder.omnitongue ? "enabled" : "disabled"] the ability to speak all languages (that_they know) of [key_name(AM)].")
				. = TRUE
