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
	data["teams"] = list()
	data["enabled"] = ""
	for(var/obj/machinery/capture_the_flag/team in GLOB.machines)
		var/list/this = list()
		this["name"] = team
		this["color"] = team.team
		this["score"] = team.points + team.control_points
		this["team_size"] = team.team_members.len
		this["refs"] += "[REF(team)]"	
		data["teams"] += list(this)
		if(!data["enabled"])
			if(team.ctf_enabled)
				data["enabled"] = "CTF is currently running!"
			else
				data["enabled"] = "CTF needs [CTF_REQUIRED_PLAYERS] players to start, currently [team.people_who_want_to_play.len]/[CTF_REQUIRED_PLAYERS] have signed up!"
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
