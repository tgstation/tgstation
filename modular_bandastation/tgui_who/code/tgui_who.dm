/datum/tgui_who
	/// If true, modal window with additional mob info is open. Admin only.
	var/modal_open = FALSE
	/// Weakref to selected mob for advanced info. Admin only.
	var/datum/weakref/mob_subject_ref = null

/datum/tgui_who/ui_state()
	return GLOB.always_state

/datum/tgui_who/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Who")
		ui.open()

/datum/tgui_who/ui_data(mob/user)
	var/list/data = list()
	var/client/viewer = user.client
	data["user"] = list(
		"key" = viewer.key,
		"ping" = list(
			"lastPing" = viewer.lastping,
			"avgPing" = viewer.avgping,
		),
		"admin"  = !!viewer.holder,
	)
	data["modalOpen"] = modal_open

	if(modal_open)
		data["subject"] = get_subject_ui_data()

	return data

/datum/tgui_who/ui_static_data(mob/user)
	var/list/data = list()

	var/list/clients = list()
	for(var/client/client as anything in GLOB.clients)
		var/list/client_data = list()
		client_data["key"] = client.key
		client_data["ping"] = list(
			"lastPing" = client.lastping,
			"avgPing" = client.avgping,
		)

		// More info for admins
		if(user.client.holder && check_rights(R_ADMIN, FALSE))
			client_data["status"] = get_status(client.mob)
			client_data["mobRef"] = REF(client.mob)
			client_data["accountAge"] = client.account_age
			client_data["byondVersion"] = "[client.byond_version].[client.byond_build]"

		clients[client] = client_data

	data["clients"] = clients
	return data

/datum/tgui_who/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	// Free to use by anyone
	switch(action)
		if("update")
			update_static_data(user)
			return TRUE

		if("hide_more_info")
			hide_more_info()
			return TRUE

	if(!check_rights(R_ADMIN))
		return FALSE

	var/mob/user_subject = locate(params["ref"])
	if(!user_subject)
		return FALSE

	if(!ismob(user_subject))
		to_chat(user.client, "Просматривать дополнительную информацию, можно только у /mob.")
		return FALSE

	// Admin only actions
	switch(action)
		if("show_more_info")
			modal_open = TRUE
			mob_subject_ref = WEAKREF(user_subject)
			RegisterSignal(user_subject, COMSIG_QDELETING, PROC_REF(on_subject_qdeleting))
			return TRUE

		if("follow")
			if(!isobserver(user))
				return FALSE

			user.client.admin_follow(user_subject)
			return TRUE

		if("logs")
			show_individual_logging_panel(user_subject)
			return TRUE

		if("smite")
			SSadmin_verbs.dynamic_invoke_verb(user.client, /datum/admin_verb/admin_smite, user_subject)
			return TRUE

		if("subtlepm")
			SSadmin_verbs.dynamic_invoke_verb(user.client, /datum/admin_verb/cmd_admin_subtle_message, user_subject)
			return TRUE

		if("view_variables")

			user.client.debug_variables(user_subject)
			return TRUE

		if("traitor_panel")
			if(!SSticker.HasRoundStarted())
				tgui_alert(user.client, "Игра ещё не началась!")
				return FALSE

			SSadmin_verbs.dynamic_invoke_verb(user.client, /datum/admin_verb/show_traitor_panel, user_subject)
			return TRUE

		if("player_panel")
			SSadmin_verbs.dynamic_invoke_verb(user.client, /datum/admin_verb/show_player_panel, user_subject)
			return TRUE

/datum/tgui_who/proc/get_subject_ui_data()
	var/mob/subject = mob_subject_ref?.resolve()
	if(isnull(subject))
		return list()

	return list(
		"key" = subject.client.key,
		"ckey" = subject.client.ckey,
		"ping" = list(
			"lastPing" = subject.client.lastping,
			"avgPing" = subject.client.avgping,
		),
		"name" = list(
			"real" = subject?.real_name,
			"mind" = subject?.mind?.name,
		),
		"role" = get_role(subject),
		"type" = subject.type,
		"gender" = subject.gender,
		"state" = get_state(subject),
		"health" = get_health(subject),
		"location" = get_position(subject),
		"accountAge" = subject.client.account_age,
		"accountIp" = subject.client.address,
		"byondVersion" = "[subject.client.byond_version].[subject.client.byond_build]",
	)

/datum/tgui_who/proc/get_status(mob/user)
	var/list/status = list()
	if(isnewplayer(user))
		status["where"] = "Неизвестно"
	else
		status["where"] = "[user.real_name]"

	status["antagonist"] = user.is_antag()
	status["state"] = get_state(user)
	return status

/datum/tgui_who/proc/get_state(mob/user)
	switch(user.stat)
		if(CONSCIOUS)
			return "Живой"
		if(UNCONSCIOUS)
			return "Без сознания"
		if(SOFT_CRIT, HARD_CRIT)
			return "В крите"
		if(DEAD)
			if(isnewplayer(user))
				return "В лобби"

			if(isobserver(user))
				var/mob/dead/observer/observer = user
				if(observer.started_as_observer)
					return "Наблюдает"
				return "Мёртв"

/datum/tgui_who/proc/get_health(mob/living/user)
	if(!isliving(user))
		return

	var/list/health = list()
	health["brute"] = user.get_brute_loss()
	health["burn"] = user.get_fire_loss()
	health["toxin"] = user.get_tox_loss()
	health["oxygen"] = user.get_oxy_loss()
	health["brain"] = user.get_organ_loss(ORGAN_SLOT_BRAIN)
	health["stamina"] = user.get_stamina_loss()
	return health

/datum/tgui_who/proc/get_position(mob/user)
	var/turf/position = get_turf(user)
	if(!isturf(position))
		return

	var/list/location_info = list()
	location_info["area"] = get_area_name(position, TRUE) || get_area_name(user, TRUE)
	location_info["x"] = position.x
	location_info["y"] = position.y
	location_info["z"] = position.z
	return location_info

/datum/tgui_who/proc/get_role(mob/living/user)
	if(!user.mind)
		return

	var/list/role = list()
	role["assigned"] = job_title_ru(user.mind.assigned_role.title)
	role["antagonist"] = user.mind.antag_datums
	return role

/datum/tgui_who/proc/on_subject_qdeleting()
	SIGNAL_HANDLER

	hide_more_info()

/datum/tgui_who/proc/hide_more_info()
	var/mob/subject = mob_subject_ref?.resolve()
	if(!isnull(subject))
		UnregisterSignal(subject, COMSIG_QDELETING)

	mob_subject_ref = null
	modal_open = FALSE

/client
	/// Reference to existing tgui_who datum, created in `client/proc/who()`.
	/// Used to avoid spam of creating those datums.
	var/datum/tgui_who/who = null

/client/who()
	set name = "Who"
	set category = "OOC"

	if(isnull(who))
		who = new()

	who.ui_interact(mob)
