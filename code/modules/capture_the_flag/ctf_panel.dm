GLOBAL_DATUM_INIT(ctf_panel, /datum/ctf_panel, new())

/datum/ctf_panel

/datum/ctf_panel/ui_state(mob/user)
	return GLOB.observer_state

/datum/ctf_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CTFPanel")
		ui.open()

/datum/ctf_panel/ui_data(mob/user)
	var/list/data = list()
	var/list/teams = list()

	for(var/game_reference in GLOB.ctf_games)
		var/datum/ctf_controller/ctf_controller = GLOB.ctf_games[game_reference]
		for(var/datum/ctf_team/team_reference as anything in ctf_controller.teams)
			if (!ctf_controller.ctf_enabled)
				continue
			var/datum/ctf_team/team = ctf_controller.teams[team_reference]

			var/list/this = list()
			this["name"] = "[team.team_color] team"
			this["color"] = team.team_color
			this["score"] = team.points
			this["team_size"] = team.team_members.len
			this["refs"] += REF(team.spawner)
			teams += list(this)

	if (teams.len == 0)
		// No CTF map has been spawned in yet
		var/datum/ctf_voting_controller/ctf_voting_controller = get_ctf_voting_controller(CTF_GHOST_CTF_GAME_ID)

		data["voters"] = ctf_voting_controller.volunteers.len
		data["voters_required"] = CTF_REQUIRED_PLAYERS
		data["voted"] = (user.ckey in ctf_voting_controller.volunteers)
	else
		data["teams"] = teams

	return data


/datum/ctf_panel/ui_act(action, params, datum/tgui/ui)
	.= ..()
	if(.)
		return
	var/mob/user = ui.user

	switch(action)
		if("jump")
			var/obj/machinery/ctf/spawner/ctf_spawner = locate(params["refs"])
			if(istype(ctf_spawner))
				user.forceMove(get_turf(ctf_spawner))
				return TRUE
		if("join")
			var/obj/machinery/ctf/spawner/ctf_spawner = locate(params["refs"])
			if(istype(ctf_spawner))
				if(ctf_enabled())
					user.forceMove(get_turf(ctf_spawner))
				ctf_spawner.attack_ghost(user)
				return TRUE
		if ("vote")
			if (ctf_enabled())
				to_chat(user, span_warning("CTF is already enabled!"))
				return TRUE

			var/datum/ctf_voting_controller/ctf_controller = get_ctf_voting_controller(CTF_GHOST_CTF_GAME_ID)
			ctf_controller.vote(user)

			return TRUE
		if ("unvote")
			if (ctf_enabled())
				to_chat(user, span_warning("CTF is already enabled!"))
				return TRUE

			var/datum/ctf_voting_controller/ctf_controller = get_ctf_voting_controller(CTF_GHOST_CTF_GAME_ID)
			ctf_controller.unvote(user)

			return TRUE

/datum/ctf_panel/proc/ctf_enabled()
	var/datum/ctf_controller/ctf_enabled_check = GLOB.ctf_games[CTF_GHOST_CTF_GAME_ID]
	if(ctf_enabled_check.ctf_enabled)
		return TRUE
	return FALSE
