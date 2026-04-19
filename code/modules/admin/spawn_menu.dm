/datum/spawn_menu
	/// Does the menu default to a regex prefix?
	var/regex_search = FALSE
	/// Does the search include atom names?
	var/name_search = TRUE
	/// Should we display full typepaths or the condensed versions?
	var/fancy_types = TRUE
	/// Should abstract types be included in the search?
	var/include_abstracts = FALSE
	/// Initial search value from the latest command
	var/init_value = null

/datum/spawn_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "SpawnSearch")
		ui.open()

/datum/spawn_menu/ui_state(mob/user)
	return ADMIN_STATE(R_SPAWN)

/datum/spawn_menu/ui_act(action, params, datum/tgui/ui)
	if (..() || !check_rights_for(ui.user.client, R_SPAWN))
		return FALSE

	switch (action)
		if ("setRegexSearch")
			regex_search = params["regexSearch"]
			return TRUE

		if ("setNameSearch")
			name_search = params["searchNames"]
			return TRUE

		if ("setFancyTypes")
			fancy_types = params["fancyTypes"]
			return TRUE

		if ("setIncludeAbstracts")
			include_abstracts = params["includeAbstracts"]
			return TRUE

		if ("spawn")
			var/path = text2path(params["type"])
			if (!path)
				return TRUE
			var/amount = clamp(text2num(params["amount"]) || 1, 1, ADMIN_SPAWN_CAP)
			var/turf/target_turf = get_turf(ui.user)
			if(ispath(path, /turf))
				target_turf.ChangeTurf(path)
			else
				for(var/i in 1 to amount)
					var/atom/spawned = new path(target_turf)
					spawned.flags_1 |= ADMIN_SPAWNED_1

			log_admin("[key_name(ui.user)] spawned [amount] x [path] at [AREACOORD(ui.user)]")
			SStgui.close_uis(src)
			return TRUE

		if ("cancel")
			SStgui.close_uis(src)
			return TRUE

/datum/spawn_menu/ui_data(mob/user)
	var/list/data = list()
	data["initValue"] = init_value
	data["searchNames"] = name_search
	data["regexSearch"] = regex_search
	data["fancyTypes"] = fancy_types
	data["includeAbstracts"] = include_abstracts
	return data

/datum/spawn_menu/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/json/spawn_menu),
	)

/datum/asset/json/spawn_menu
	name = "spawn_menu_atom_data"

/datum/asset/json/spawn_menu/generate()
	var/list/data = list()
	var/static/list/types_list
	if (isnull(types_list))
		var/list/local_types = list()
		for (var/atom/atom_type as anything in subtypesof(/atom))
			local_types[atom_type] = atom_type::name || ""
		types_list = local_types
	data["types"] = types_list
	data["abstractTypes"] = get_abstract_types()
	data["fancyTypes"] = GLOB.fancy_type_replacements
	return data
