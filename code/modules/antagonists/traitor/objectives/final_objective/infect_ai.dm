/datum/traitor_objective/ultimate/infect_ai
	name = "Infect the station AI with an experimental virus."
	description = "Infect the station AI with an experimental virus. Go to %AREA% to receive an infected law upload board \
		and use it on the AI core or a law upload console."

	///area type the objective owner must be in to receive the law upload module
	var/area/board_area_pickup
	///checker on whether we have sent the law upload module
	var/sent_board = FALSE

/datum/traitor_objective/ultimate/infect_ai/can_generate_objective(generating_for, list/possible_duplicates)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/silicon/ai/ai in GLOB.ai_list)
		if(ai.stat == DEAD || ai.mind?.has_antag_datum(/datum/antagonist/malf_ai) || !is_station_level(ai.z))
			continue
		return TRUE

	return FALSE

/datum/traitor_objective/ultimate/infect_ai/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/list/possible_areas = GLOB.the_station_areas.Copy()
	for(var/area/possible_area as anything in possible_areas)
		//remove areas too close to the destination, too obvious for our poor shmuck, or just unfair
		if(istype(possible_area, /area/station/hallway) || istype(possible_area, /area/station/security))
			possible_areas -= possible_area
	if(!length(possible_areas))
		return FALSE
	board_area_pickup = pick(possible_areas)
	replace_in_name("%AREA%", initial(board_area_pickup.name))
	return TRUE

/datum/traitor_objective/ultimate/infect_ai/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!sent_board)
		buttons += add_ui_button("", "Pressing this will call down a pod with an infected law upload board.", "wifi", "upload_board")
	return buttons

/datum/traitor_objective/ultimate/infect_ai/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("upload_board")
			if(sent_board)
				return
			var/area/delivery_area = get_area(user)
			if(delivery_area.type != board_area_pickup)
				to_chat(user, span_warning("You must be in [initial(board_area_pickup.name)] to receive the infected law upload board."))
				return
			sent_board = TRUE
			podspawn(list(
				"target" = get_turf(user),
				"style" = /datum/pod_style/syndicate,
				"spawn" = /obj/item/ai_module/malf,
			))
