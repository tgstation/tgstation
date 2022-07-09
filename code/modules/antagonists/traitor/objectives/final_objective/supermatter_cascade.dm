/datum/traitor_objective/final/supermatter_cascade
	name = "Destroy the station by causing a crystallizing resonance cascade"
	description = "Destroy the station by causing a supermatter cascade. Go to %AREA% to retrieve the destabilizing crystal \
		and use it on the supermatter."

	///area type the objective owner must be in to recieve the destabilizing crystal
	var/area/dest_crystal_area_pickup
	///checker on whether we have sent the crystal yet.
	var/sent_crystal = FALSE

/datum/traitor_objective/final/supermatter_cascade/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(!can_take_final_objective())
		return
	var/list/possible_areas = GLOB.the_station_areas.Copy()
	for(var/area/possible_area as anything in possible_areas)
		//remove areas too close to the destination, too obvious for our poor shmuck, or just unfair
		if(istype(possible_area, /area/station/hallway) || istype(possible_area, /area/station/security))
			possible_areas -= possible_area
	dest_crystal_area_pickup = pick(possible_areas)
	replace_in_name("%AREA%", initial(dest_crystal_area_pickup.name))
	return TRUE

/datum/traitor_objective/final/supermatter_cascade/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!sent_crystal)
		buttons += add_ui_button("", "Pressing this will call down a pod with the supermatter cascade kit.", "biohazard", "destabilizing_crystal")
	return buttons

/datum/traitor_objective/final/supermatter_cascade/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("destabilizing_crystal")
			if(sent_crystal)
				return
			var/area/delivery_area = get_area(user)
			if(delivery_area.type != dest_crystal_area_pickup)
				to_chat(user, span_warning("You must be in [initial(dest_crystal_area_pickup.name)] to receive the supermatter cascade kit."))
				return
			sent_crystal = TRUE
			podspawn(list(
				"target" = get_turf(user),
				"style" = STYLE_SYNDICATE,
				"spawn" = /obj/item/destabilizing_crystal,
			))
