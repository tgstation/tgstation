/datum/traitor_objective/ultimate/no_escape
	name = "Attach a beacon to the escape shuttle that will attract a singularity to consume everything."
	description = "Go to %AREA%, and receive the smuggled beacon. Set up the beacon anywhere on the shuttle, \
	and charge it using an inducer then, IT COMES. Warning: The singularity will consume all in it's path, you included."

	///area type the objective owner must be in to receive the satellites
	var/area/beacon_spawn_area_type
	///checker on whether we have sent the beacon yet
	var/sent_beacon = FALSE

/datum/traitor_objective/ultimate/no_escape/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/list/possible_areas = GLOB.the_station_areas.Copy()
	for(var/area/possible_area as anything in possible_areas)
		if(!ispath(possible_area, /area/station/maintenance/solars) && !ispath(possible_area, /area/station/solars))
			possible_areas -= possible_area
	if(length(possible_areas) == 0)
		return FALSE
	beacon_spawn_area_type = pick(possible_areas)
	replace_in_name("%AREA%", initial(beacon_spawn_area_type.name))
	return TRUE

/datum/traitor_objective/ultimate/no_escape/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!sent_beacon)
		buttons += add_ui_button("", "Pressing this will call down a pod with the smuggled beacon.", "beacon", "beacon")
	return buttons

/datum/traitor_objective/ultimate/no_escape/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("beacon")
			if(sent_beacon)
				return
			var/area/delivery_area = get_area(user)
			if(delivery_area.type != beacon_spawn_area_type)
				to_chat(user, span_warning("You must be in [initial(beacon_spawn_area_type.name)] to receive the smuggled beacon."))
				return
			sent_beacon = TRUE
			podspawn(list(
				"target" = get_turf(user),
				"style" = /datum/pod_style/syndicate,
				"spawn" = list(
					/obj/item/sbeacondrop/no_escape,
					/obj/item/inducer/syndicate,
					/obj/item/wrench
				)
			))

