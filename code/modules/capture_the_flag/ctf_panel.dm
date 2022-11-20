GLOBAL_DATUM_INIT(ctf_panel, /datum/ctf_panel, new())

/datum/ctf_panel
	///List of all CTF machines
	var/list/obj/machinery/capture_the_flag/ctf_machines = list()

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

	for(var/obj/machinery/capture_the_flag/team as anything in GLOB.ctf_panel.ctf_machines)
		if (!team.ctf_enabled)
			continue

		var/list/this = list()
		this["name"] = team
		this["color"] = team.team
		this["score"] = team.points + team.control_points
		this["team_size"] = team.team_members.len
		this["refs"] += REF(team)
		teams += list(this)

	if (teams.len == 0)
		// No CTF map has been spawned in yet
		var/datum/ctf_voting_controller/ctf_controller = get_ctf_voting_controller(CTF_GHOST_CTF_GAME_ID)

		data["voters"] = ctf_controller.volunteers.len
		data["voters_required"] = CTF_REQUIRED_PLAYERS
		data["voted"] = (user.ckey in ctf_controller.volunteers)
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
			var/obj/machinery/capture_the_flag/ctf_spawner = locate(params["refs"])
			if(istype(ctf_spawner))
				user.forceMove(get_turf(ctf_spawner))
				return TRUE
		if("join")
			var/obj/machinery/capture_the_flag/ctf_spawner = locate(params["refs"])
			if(istype(ctf_spawner))
				if(ctf_spawner.ctf_enabled)
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
	for (var/obj/machinery/capture_the_flag/ctf_machine as anything in GLOB.ctf_panel.ctf_machines)
		if (ctf_machine.ctf_enabled)
			return TRUE

	return FALSE
