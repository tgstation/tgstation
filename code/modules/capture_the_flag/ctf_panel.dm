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
	for(var/obj/machinery/capture_the_flag/team in GLOB.machines)
		var/list/this = list()
		this["name"] = team
		this["score"] = team.points + team.control_points
		this["refs"] += "[REF(team)]"	
		data["teams"] += list(this)		
	return data


/datum/ctf_panel/ui_act(action, params, datum/tgui/ui)
	.= ..()
	if(.)
		return
	var/mob/user = ui.user

	switch(action)
		if("jump")
			var/obj/machinery/capture_the_flag/ctf_spawner = locate(params["refs"]) in GLOB.machines 
			if(ctf_spawner)
				user.forceMove(get_turf(ctf_spawner))
				return TRUE
