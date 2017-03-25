/datum/language_menu
	var/mob/living/owner

/datum/language_menu/New(new_owner)
	..()
	owner = new_owner

/datum/language_menu/Destroy()
	owner = null
	. = ..()

/datum/language_menu/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = language_menu_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "language_menu", "Language Menu", 700, 800, master_ui, state)
		ui.open()

/datum/language_menu/ui_data(mob/user)
	var/list/data = list()

	var/datum/language/mob_default_language = owner.get_default_language()

	data["languages"] = list()
	for(var/ld in owner.languages)
		var/datum/language/LD = ld
		var/list/L = list()

		L["name"] = initial(LD.name)
		L["desc"] = initial(LD.desc)
		L["key"] = initial(LD.key)
		L["is_default"] = (LD == mob_default_language)
		L["can_speak"] = owner.can_speak_in_language(LD)

		data["languages"] += list(L)

	if(check_rights_for(user.client, R_ADMIN))
		data["admin_mode"] = TRUE
		data["can_always_speak"] = HAS_SECONDARY_FLAG(owner, CAN_ALWAYS_SPEAK_A_LANGUAGE)

		data["unknown_languages"] = list()
		for(var/ld in subtypesof(/datum/language))
			if(owner.has_language(ld))
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

	var/language_name = params["language_name"]
	var/datum/language/language_datum
	for(var/ld in subtypesof(/datum/language))
		var/datum/language/LD = ld
		if(language_name == initial(LD.name))
			language_datum = LD
	var/is_admin = check_rights_for(user.client, R_ADMIN)

	switch(action)
		if("select_default")
			if(language_datum)
				owner.selected_default_language = language_datum
				. = TRUE
		if("grant_language")
			if(is_admin && language_datum)
				owner.grant_language(language_datum)
				message_admins("[key_name_admin(user)] granted the [language_name] language to [key_name_admin(owner)].")
				log_admin("[key_name(user)] granted the language [language_name] to [key_name(owner)].")
				. = TRUE
		if("remove_language")
			if(is_admin && language_datum)
				owner.remove_language(language_datum)
				message_admins("[key_name_admin(user)] removed the [language_name] language to [key_name_admin(owner)].")
				log_admin("[key_name(user)] removed the language [language_name] to [key_name(owner)].")
				. = TRUE
		if("toggle_can_always_speak")
			if(is_admin)
				TOGGLE_SECONDARY_FLAG(owner, CAN_ALWAYS_SPEAK_A_LANGUAGE)
				message_admins("[key_name_admin(user)] [HAS_SECONDARY_FLAG(owner, CAN_ALWAYS_SPEAK_A_LANGUAGE) ? "enabled" : "disabled"] the ability to speak all languages of [key_name_admin(owner)].")
				log_admin("[key_name(user)] [HAS_SECONDARY_FLAG(owner, CAN_ALWAYS_SPEAK_A_LANGUAGE) ? "enabled" : "disabled"] the ability to speak all languages of [key_name(owner)].")
				. = TRUE
