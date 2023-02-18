/datum/computer_file/program/themeify
	filename = "themeify"
	filedesc = "Themeify"
	extended_desc = "This program allows configuration of your device's theme."
	program_icon_state = "generic"
	undeletable = TRUE
	size = 0
	header_program = TRUE
	available_on_ntnet = TRUE
	requires_ntnet = FALSE
	tgui_id = "NtosThemeConfigure"
	program_icon = "paint-roller"

	///List of all themes imported from maintenance apps.
	var/list/imported_themes = list()

/datum/computer_file/program/themeify/ui_data(mob/user)
	var/list/data = get_header_data()

	if(computer.obj_flags & EMAGGED)
		data["themes"] += list(list("theme_name" = SYNDICATE_THEME_NAME, "theme_ref" = GLOB.pda_name_to_theme[SYNDICATE_THEME_NAME]))
	for(var/theme_key in GLOB.default_pda_themes + imported_themes)
		data["themes"] += list(list("theme_name" = theme_key, "theme_ref" = GLOB.pda_name_to_theme[theme_key]))

	return data

/datum/computer_file/program/themeify/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("PRG_change_theme")
			var/selected_theme = params["selected_theme"]
			if(!GLOB.default_pda_themes.Find(selected_theme) && !imported_themes.Find(selected_theme) && !(computer.obj_flags & EMAGGED))
				return FALSE
			computer.device_theme = GLOB.pda_name_to_theme[selected_theme]
			return TRUE
