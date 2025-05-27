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
		if("restore_appearance")
			restore_ghost_appearance(dead_user)
			return TRUE
		if("change_notification")
			var/key = params["key"]
			if(key && islist(GLOB.poll_ignore[key]))
				GLOB.poll_ignore[key] ^= list(dead_user.ckey)
			return TRUE
		if("toggle_visibility")
			var/to_toggle = params["toggling"]
			switch(to_toggle)
				if("tray_scan")
					tray_view(dead_user)
				if("chem_scan")
					toggle_chem_scan(dead_user)
				if("health_scan")
					toggle_health_scan(dead_user)
				if("gas_scan")
					toggle_gas_scan(dead_user)
				if("darkness")
					toggle_darkness(dead_user)
				if("hud")
					toggle_data_huds(dead_user)
				if("ghost_vision")
					toggle_ghost_vision(dead_user)
			return TRUE
		if("crew_manifest")
			GLOB.manifest.ui_interact(dead_user)
			return TRUE
		if("view_range")
			var/setting_to = params["new_view_range"]
			if(!isnum(setting_to))
				return TRUE
			set_view(dead_user, setting_to)
			return TRUE
		if("boo")
			if(!dead_user.fun_verbs)
				return TRUE
			dead_user.boo()
			return TRUE
		if("possess")
			if(!dead_user.fun_verbs)
				return TRUE
			dead_user.possess()
			return TRUE

	return FALSE

/datum/ghost_menu/ui_data(mob/dead/observer/user)
	var/list/data = list()

	data["has_fun"] = user.fun_verbs
	data["notification_data"] = list()
	for(var/key in GLOB.poll_ignore_desc)
		data["notification_data"] += list(list(
			"key" = key,
			"enabled" = (user.ckey in GLOB.poll_ignore[key]),
			"desc" = GLOB.poll_ignore_desc[key],
		))

	return data


/datum/ghost_menu/ui_static_data(mob/user)
	return ..()

///Shows the UI to the person in the args.
/datum/ghost_menu/proc/show(mob/user)
	ui_interact(user)

/datum/ghost_menu/proc/tray_view(mob/dead/observer/user)
	if(SSlag_switch.measures[DISABLE_GHOST_ZOOM_TRAY] && !user.client?.holder)
		to_chat(user, span_notice("That verb is currently globally disabled."))
		return
	t_ray_scan(user)

/datum/ghost_menu/proc/toggle_ghost_vision(mob/dead/observer/user)
	user.ghostvision = !user.ghostvision
	user.update_sight()

/datum/ghost_menu/proc/toggle_darkness(mob/dead/observer/user)
	switch(user.lighting_cutoff)
		if (LIGHTING_CUTOFF_VISIBLE)
			user.lighting_cutoff = LIGHTING_CUTOFF_MEDIUM
		if (LIGHTING_CUTOFF_MEDIUM)
			user.lighting_cutoff = LIGHTING_CUTOFF_HIGH
		if (LIGHTING_CUTOFF_HIGH)
			user.lighting_cutoff = LIGHTING_CUTOFF_FULLBRIGHT
		else
			user.lighting_cutoff = LIGHTING_CUTOFF_VISIBLE

	user.update_sight()

/datum/ghost_menu/proc/toggle_data_huds(mob/dead/observer/user)
	if(user.data_huds_on)
		user.remove_data_huds()
		to_chat(user, span_notice("Data HUDs disabled."))
		user.data_huds_on = FALSE
	else
		user.show_data_huds()
		to_chat(user, span_notice("Data HUDs enabled."))
		user.data_huds_on = TRUE

/datum/ghost_menu/proc/toggle_health_scan(mob/dead/observer/user)
	if(user.health_scan)
		to_chat(user, span_notice("Health scan disabled."))
		user.health_scan = FALSE
	else
		to_chat(user, span_notice("Health scan enabled."))
		user.health_scan = TRUE

/datum/ghost_menu/proc/toggle_chem_scan(mob/dead/observer/user)
	if(user.chem_scan)
		to_chat(user, span_notice("Chem scan disabled."))
		user.chem_scan = FALSE
	else
		to_chat(user, span_notice("Chem scan enabled."))
		user.chem_scan = TRUE

/datum/ghost_menu/proc/toggle_gas_scan(mob/dead/observer/user)
	if(user.gas_scan)
		to_chat(user, span_notice("Gas scan disabled."))
		user.gas_scan = FALSE
	else
		to_chat(user, span_notice("Gas scan enabled."))
		user.gas_scan = TRUE

/datum/ghost_menu/proc/restore_ghost_appearance(mob/dead/observer/user)
	user.set_ghost_appearance()
	if(!user.client?.prefs)
		return
	var/real_name = user.client.prefs.read_preference(/datum/preference/name/real_name)
	user.deadchat_name = user.real_name
	if(user.mind)
		user.mind.ghostname = user.real_name
	user.name = user.real_name

/datum/ghost_menu/proc/set_view(mob/dead/observer/user, new_view)
	if(SSlag_switch.measures[DISABLE_GHOST_ZOOM_TRAY] && !user.client?.holder)
		to_chat(user, span_notice("That verb is currently globally disabled."))
		return TRUE
	var/max_view = user.client.prefs.unlock_content ? GHOST_MAX_VIEW_RANGE_MEMBER : GHOST_MAX_VIEW_RANGE_DEFAULT
	if(max_view >= new_view && new_view < GHOST_MIN_VIEW_RANGE)
		return TRUE
	user.client.view_size.setTo(round(new_view, 1) - GHOST_MIN_VIEW_RANGE)
