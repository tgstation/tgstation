/datum/robot_control
	var/mob/living/silicon/ai/owner

/datum/robot_control/New(mob/living/silicon/ai/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/robot_control/proc/is_interactable(mob/user)
	if(user != owner || owner.incapacitated())
		return FALSE
	if(owner.control_disabled)
		to_chat(user, "<span class='warning'>Wireless control is disabled.</span>")
		return FALSE
	return TRUE

/datum/robot_control/ui_status(mob/user)
	if(is_interactable(user))
		return ..()
	return UI_CLOSE

/datum/robot_control/ui_state(mob/user)
	return GLOB.always_state

/datum/robot_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RemoteRobotControl")
		ui.open()

/datum/robot_control/ui_data(mob/user)
	if(!owner || user != owner)
		return
	var/list/data = list()
	var/turf/ai_current_turf = get_turf(owner)
	var/ai_zlevel = ai_current_turf.z

	data["robots"] = list()
	for(var/mob/living/simple_animal/bot/B in GLOB.bots_list)
		if(B.z != ai_zlevel || B.remote_disabled) //Only non-emagged bots on the same Z-level are detected!
			continue
		var/list/robot_data = list(
			name = B.name,
			model = B.model,
			mode = B.get_mode(),
			hacked = B.hacked,
			location = get_area_name(B, TRUE),
			ref = REF(B)
		)
		data["robots"] += list(robot_data)

	return data

/datum/robot_control/ui_act(action, params)
	if(..())
		return
	if(!is_interactable(usr))
		return

	switch(action)
		if("callbot") //Command a bot to move to a selected location.
			if(owner.call_bot_cooldown > world.time)
				to_chat(usr, "<span class='danger'>Error: Your last call bot command is still processing, please wait for the bot to finish calculating a route.</span>")
				return
			owner.Bot = locate(params["ref"]) in GLOB.bots_list
			if(!owner.Bot || owner.Bot.remote_disabled || owner.control_disabled)
				return
			owner.waypoint_mode = TRUE
			to_chat(usr, "<span class='notice'>Set your waypoint by clicking on a valid location free of obstructions.</span>")
			. = TRUE
		if("interface") //Remotely connect to a bot!
			owner.Bot = locate(params["ref"]) in GLOB.bots_list
			if(!owner.Bot || owner.Bot.remote_disabled || owner.control_disabled)
				return
			owner.Bot.attack_ai(usr)
			. = TRUE
