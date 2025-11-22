GLOBAL_LIST_INIT(spawn_menus_by_ckey, list())

/datum/spawn_menu
	/// Who this instance of spawn panel belongs to. The instances are unique to correctly keep modified values between multiple admins.
	var/owner_ckey
	/// Does the menu default to a regex prefix?
	var/regex_search = FALSE
	/// Does the search include atom names?
	var/name_search = TRUE
	/// Should we display full typepaths or the condensed versions?
	var/fancy_types = TRUE
	/// Initial search value from the latest command
	var/init_value = null

/datum/spawn_menu/New(new_owner)
	. = ..()
	owner_ckey = new_owner

/proc/get_spawn_menu_for_admin(mob/user)
	if(!user?.client?.ckey)
		return null

	var/ckey = user.client.ckey

	if(GLOB.spawn_menus_by_ckey[ckey])
		return GLOB.spawn_menus_by_ckey[ckey]

	var/datum/spawn_menu/new_menu = new(ckey)
	GLOB.spawn_menus_by_ckey[ckey] = new_menu
	return new_menu

/datum/spawn_menu/ui_interact(mob/user, datum/tgui/ui)
	if (user.client.ckey != owner_ckey)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "SpawnSearch")
		ui.open()

/datum/spawn_menu/ui_state(mob/user)
	if (user.client.ckey != owner_ckey)
		return GLOB.never_state
	return ADMIN_STATE(R_ADMIN)

/datum/spawn_menu/ui_act(action, params, datum/tgui/ui)
	if (..())
		return FALSE

	if (ui.user.ckey != owner_ckey)
		return FALSE

	switch (action)
		if ("setRegexSearch")
			regex_search = text2num(params["regexSearch"])
			SStgui.update_uis(src)
			return TRUE

		if ("setNameSearch")
			name_search = text2num(params["searchNames"])
			SStgui.update_uis(src)
			return TRUE

		if ("setFancyTypes")
			fancy_types = text2num(params["fancyTypes"])
			SStgui.update_uis(src)
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
		types_list = list()
		for (var/atom/atom_type as anything in subtypesof(/atom))
			types_list[atom_type] = atom_type::name || ""
	data["types"] = types_list
	data["abstractTypes"] = get_abstract_types()
	data["fancyTypes"] = GLOB.fancy_type_replacements
	return data
