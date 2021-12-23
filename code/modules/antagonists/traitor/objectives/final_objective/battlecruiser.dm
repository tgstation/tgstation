/datum/traitor_objective/final/battlecruiser
	name = "Reveal Station Coordinates to nearby Syndicate Battlecruiser"
	description = "Use a special upload card on a communications console to send the coordinates \
	of the station to a nearby Battlecruiser. You may want to make your syndicate status known to \
	the battlecruiser crew when they arrive, their goal will be to destroy the station."

	///checker on whether we have sent the card yet.
	var/sent_accesscard = FALSE

/datum/traitor_objective/final/battlecruiser/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!sent_accesscard)
		buttons += add_ui_button("", "Pressing this will materialize an upload card, which you can use on a communication console to contact the fleet.", "phone", "card")
	return buttons

/datum/traitor_objective/final/battlecruiser/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("card")
			if(sent_accesscard)
				return
			sent_accesscard = TRUE
			podspawn(list(
				"target" = get_turf(user),
				"style" = STYLE_SYNDICATE,
				"spawn" = /obj/item/card/emag/battlecruiser,
			))

/proc/summon_battlecruiser()
	var/list/candidates = poll_ghost_candidates("Do you wish to be considered for battlecruiser crew?", ROLE_TRAITOR)
	shuffle_inplace(candidates)

	var/datum/map_template/shuttle/battlecruiser/starfury/ship = new /datum/map_template/shuttle/battlecruiser/starfury
	var/x = rand(TRANSITIONEDGE,world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE,world.maxy - TRANSITIONEDGE - ship.height)
	var/z = SSmapping.empty_space.z_value
	var/turf/battlecruiser_loading_turf = locate(x,y,z)
	if(!battlecruiser_loading_turf)
		CRASH("Battlecruiser found no turf to load in")

	if(!ship.load(battlecruiser_loading_turf))
		CRASH("Loading battlecruiser ship failed!")

	for(var/turf/open/spawned_turf as anything in ship.get_affected_turfs(battlecruiser_loading_turf)) //not as anything to filter out closed turfs
		for(var/obj/effect/mob_spawn/ghost_role/human/syndicate/battlecruiser/spawner in spawned_turf)
			if(candidates.len > 0)
				var/mob/our_candidate = candidates[1]
				spawner.create(our_candidate)
				candidates -= our_candidate
				notify_ghosts("The battlecruiser has an object of interest: [our_candidate]!", source=our_candidate, action=NOTIFY_ORBIT, header="Something's Interesting!")
			else
				notify_ghosts("The battlecruiser has an object of interest: [spawner]!", source=spawner, action=NOTIFY_ORBIT, header="Something's Interesting!")

	priority_announce("Unidentified armed ship detected near the station.")
