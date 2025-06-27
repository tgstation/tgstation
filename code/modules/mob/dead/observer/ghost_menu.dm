GLOBAL_DATUM_INIT(ghost_menu, /datum/ghost_menu, new)

/datum/ghost_menu

/datum/ghost_menu/ui_state(mob/user)
	return GLOB.observer_state

/datum/ghost_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "GhostMenu")
		ui.open()

/datum/ghost_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/dead/observer/dead_user = ui.user
	switch(action)
		if("DNR")
			dead_user.stay_dead()
			return TRUE
		if("return_to_body")
			dead_user.reenter_corpse()
			return TRUE
		if("restore_appearance")
			restore_ghost_appearance(dead_user)
			return TRUE
		if("change_notification")
			var/key = params["key"]
			if(key && islist(GLOB.poll_ignore[key]))
				GLOB.poll_ignore[key] ^= list(dead_user.ckey)
			return TRUE
		if("turn_all_on")
			for(var/key in GLOB.poll_ignore)
				GLOB.poll_ignore[key] &= ~list(dead_user.ckey)
			return TRUE
		if("turn_all_off")
			for(var/key in GLOB.poll_ignore)
				GLOB.poll_ignore[key] |= list(dead_user.ckey)
			return TRUE
		if("signup_pai")
			SSpai.recruit_window(dead_user)
			return TRUE
		if("tray_scan")
			tray_view(dead_user)
			return TRUE
		if("darkness")
			var/darkness_type = params["darkness_level"]
			if(isnull(darkness_type))
				return FALSE
			for(var/lighting_types in GLOB.ghost_lightings)
				if(darkness_type != lighting_types)
					continue
				//our selected one is the one we already have enabled.
				if(dead_user.lighting_cutoff == GLOB.ghost_lightings[darkness_type])
					return FALSE
				toggle_darkness(dead_user, darkness_type)
				return TRUE
		if("toggle_visibility")
			var/to_toggle = params["toggling"]
			if(!(to_toggle in ALL_GHOST_FLAGS))
				return
			toggle_hud_type(dead_user, to_toggle)
			return TRUE
		if("crew_manifest")
			GLOB.manifest.ui_interact(dead_user)
			return TRUE
		if("view_range")
			var/setting_to = text2num(params["new_view_range"]) + GHOST_MIN_VIEW_RANGE
			if(!isnum(setting_to))
				return FALSE
			set_view(dead_user, setting_to)
			return TRUE
		if("boo")
			if(!dead_user.fun_verbs)
				return FALSE
			dead_user.boo()
			return TRUE
		if("possess")
			if(!dead_user.fun_verbs)
				return FALSE
			dead_user.possess()
			return TRUE

	return FALSE

/datum/ghost_menu/ui_data(mob/dead/observer/user)
	var/list/data = list()

	data["can_boo"] = COOLDOWN_FINISHED(user, bootime)
	data["has_fun"] = user.fun_verbs
	data["body_name"] = (user.can_reenter_corpse && user?.mind.current) ? user.mind.current.real_name : FALSE
	for(var/level in GLOB.ghost_lightings)
		if(GLOB.ghost_lightings[level] == user.lighting_cutoff)
			data["current_darkness"] = level
	data["notification_data"] = list()
	for(var/key in GLOB.poll_ignore_desc)
		data["notification_data"] += list(list(
			"key" = key,
			"enabled" = !!(user.ckey in GLOB.poll_ignore[key]),
			"desc" = GLOB.poll_ignore_desc[key],
		))

	data["hud_info"] = list(
		list(
			"name" = "Data HUDs",
			"enabled" = (user.ghost_hud_flags & GHOST_DATA_HUDS),
			"flag" = GHOST_DATA_HUDS,
			"tooltip" = "Grants you Med/Sec/Diag HUDs.",
		),
		list(
			"name" = "Ghost Vision",
			"enabled" = (user.ghost_hud_flags & GHOST_VISION),
			"flag" = GHOST_VISION,
			"tooltip" = "Allows you to see ghost-only things (ex: smuggler satchels, countdowns, camera eyes).",
		),
		list(
			"name" = "Health Scanner",
			"enabled" = (user.ghost_hud_flags & GHOST_HEALTH),
			"flag" = GHOST_HEALTH,
			"tooltip" = "Allows you to perform a health scan by clicking on someone.",
		),
		list(
			"name" = "Chemical Scanner",
			"enabled" = (user.ghost_hud_flags & GHOST_CHEM),
			"flag" = GHOST_CHEM,
			"tooltip" = "Allows you to perform a chemical scan by clicking on someone.",
		),
		list(
			"name" = "Gas Scanner",
			"enabled" = (user.ghost_hud_flags & GHOST_GAS),
			"flag" = GHOST_GAS,
			"tooltip" = "Allows you to perform a gas scan by clicking on a tile/atmos machine.",
		),
	)

	return data

/datum/ghost_menu/ui_static_data(mob/dead/observer/user)
	var/list/data = list()
	data["max_extra_view"] = (user.client.prefs.unlock_content ? GHOST_MAX_VIEW_RANGE_MEMBER : GHOST_MAX_VIEW_RANGE_DEFAULT) - GHOST_MIN_VIEW_RANGE
	data["darkness_levels"] = list()
	for(var/level in GLOB.ghost_lightings)
		data["darkness_levels"] += level
	data["lag_switch_on"] = !!(SSlag_switch.measures[DISABLE_GHOST_ZOOM_TRAY] && !user.client?.holder)
	return data

/datum/ghost_menu/proc/tray_view(mob/dead/observer/user)
	if(SSlag_switch.measures[DISABLE_GHOST_ZOOM_TRAY] && !user.client?.holder)
		to_chat(user, span_notice("That verb is currently globally disabled."))
		return
	t_ray_scan(user)

/datum/ghost_menu/proc/toggle_darkness(mob/dead/observer/user, darkness_type)
	user.client.prefs.write_preference(GLOB.preference_entries[/datum/preference/choiced/ghost_lighting], darkness_type)
	user.lighting_cutoff = user.default_lighting_cutoff()
	user.update_sight()

/datum/ghost_menu/proc/toggle_hud_type(mob/dead/observer/user, hud_type)
	user.ghost_hud_flags ^= hud_type
	//special aftereffects for specific flags.
	switch(hud_type)
		if(GHOST_VISION)
			user.update_sight()
		if(GHOST_DATA_HUDS)
			if(user.ghost_hud_flags & GHOST_DATA_HUDS)
				user.show_data_huds()
			else
				user.remove_data_huds()

/datum/ghost_menu/proc/restore_ghost_appearance(mob/dead/observer/user)
	user.set_ghost_appearance()
	if(!user.client?.prefs)
		return
	var/real_name_pref = user.client.prefs.read_preference(/datum/preference/name/real_name)
	user.deadchat_name = real_name_pref
	if(user.mind)
		user.mind.ghostname = real_name_pref
	user.name = real_name_pref

/datum/ghost_menu/proc/set_view(mob/dead/observer/user, new_view)
	if(SSlag_switch.measures[DISABLE_GHOST_ZOOM_TRAY] && !user.client?.holder)
		to_chat(user, span_notice("That verb is currently globally disabled."))
		return TRUE
	var/max_view = user.client.prefs.unlock_content ? GHOST_MAX_VIEW_RANGE_MEMBER : GHOST_MAX_VIEW_RANGE_DEFAULT
	if(max_view >= new_view && new_view < GHOST_MIN_VIEW_RANGE)
		return TRUE
	user.client.view_size.setTo(round(new_view, 1) - GHOST_MIN_VIEW_RANGE)
