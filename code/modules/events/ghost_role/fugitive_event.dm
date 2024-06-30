#define TEAM_BACKSTORY_SIZE 4

/datum/round_event_control/fugitives
	name = "Spawn Fugitives"
	typepath = /datum/round_event/ghost_role/fugitives
	max_occurrences = 1
	min_players = 20
	earliest_start = 30 MINUTES //deadchat sink, lets not even consider it early on.
	category = EVENT_CATEGORY_INVASION
	description = "Fugitives will hide on the station, followed by hunters."
	map_flags = EVENT_SPACE_ONLY

/datum/round_event/ghost_role/fugitives
	minimum_required = 1
	role_name = "fugitive"
	fakeable = FALSE

/datum/round_event/ghost_role/fugitives/spawn_role()
	var/turf/landing_turf = find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = FALSE)
	if(isnull(landing_turf))
		return MAP_ERROR
	var/list/possible_backstories = list()
	var/list/candidates = SSpolling.poll_ghost_candidates(check_jobban = ROLE_FUGITIVE, role = ROLE_FUGITIVE, alert_pic = /obj/item/card/id/advanced/prisoner, jump_target = landing_turf)

	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	if(length(candidates) < TEAM_BACKSTORY_SIZE || prob(30 - (length(candidates) * 2))) //Solo backstories are always considered if a larger backstory cannot be filled out. Otherwise, it's a rare chance that gets rarer if more people sign up.
		possible_backstories += list(FUGITIVE_BACKSTORY_WALDO, FUGITIVE_BACKSTORY_INVISIBLE) //less common as it comes with magicks and is kind of immershun shattering

	if(length(candidates) >= TEAM_BACKSTORY_SIZE)//group refugees
		possible_backstories += list(FUGITIVE_BACKSTORY_PRISONER, FUGITIVE_BACKSTORY_CULTIST, FUGITIVE_BACKSTORY_SYNTH)

	var/backstory = pick(possible_backstories)
	var/member_size = 3
	var/leader
	switch(backstory)
		if(FUGITIVE_BACKSTORY_SYNTH)
			leader = pick_n_take(candidates)
		if(FUGITIVE_BACKSTORY_WALDO, FUGITIVE_BACKSTORY_INVISIBLE)
			member_size = 0 //solo refugees have no leader so the member_size gets bumped to one a bit later
	var/list/members = list()
	var/list/spawned_mobs = list()
	if(isnull(leader))
		member_size++ //if there is no leader role, then the would be leader is a normal member of the team.

	for(var/i in 1 to member_size)
		members += pick_n_take(candidates)

	for(var/mob/dead/selected in members)
		var/mob/living/carbon/human/S = gear_fugitive(selected, landing_turf, backstory)
		spawned_mobs += S
	if(!isnull(leader))
		gear_fugitive_leader(leader, landing_turf, backstory)

	//after spawning
	playsound(src, 'sound/weapons/emitter.ogg', 50, TRUE)
	new /obj/item/storage/toolbox/mechanical(landing_turf) //so they can actually escape maint
	var/hunter_backstory = pick(
		HUNTER_PACK_COPS,
		HUNTER_PACK_RUSSIAN,
		HUNTER_PACK_BOUNTY,
		HUNTER_PACK_PSYKER,
	)
	addtimer(CALLBACK(src, PROC_REF(check_spawn_hunters), hunter_backstory, 10 MINUTES), 1 MINUTES)
	role_name = "fugitive hunter"
	return SUCCESSFUL_SPAWN

/datum/round_event/ghost_role/fugitives/proc/gear_fugitive(mob/dead/selected, turf/landing_turf, backstory) //spawns normal fugitive
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE
	var/mob/living/carbon/human/S = new(landing_turf)
	player_mind.transfer_to(S)
	player_mind.set_assigned_role(SSjob.GetJobType(/datum/job/fugitive))
	player_mind.special_role = ROLE_FUGITIVE
	player_mind.add_antag_datum(/datum/antagonist/fugitive)
	var/datum/antagonist/fugitive/fugitiveantag = player_mind.has_antag_datum(/datum/antagonist/fugitive)
	fugitiveantag.greet(backstory)

	switch(backstory)
		if(FUGITIVE_BACKSTORY_PRISONER)
			S.equipOutfit(/datum/outfit/prisoner)
		if(FUGITIVE_BACKSTORY_CULTIST)
			S.equipOutfit(/datum/outfit/yalp_cultist)
		if(FUGITIVE_BACKSTORY_WALDO)
			S.equipOutfit(/datum/outfit/waldo)
		if(FUGITIVE_BACKSTORY_SYNTH)
			S.equipOutfit(/datum/outfit/synthetic)
		if(FUGITIVE_BACKSTORY_INVISIBLE)
			S.equipOutfit(/datum/outfit/invisible_man)
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Fugitive by an event.")
	S.log_message("was spawned as a Fugitive by an event.", LOG_GAME)
	spawned_mobs += S
	return S

///special spawn for one member. it can be used for a special mob or simply to give one normal member special items.
/datum/round_event/ghost_role/fugitives/proc/gear_fugitive_leader(mob/dead/leader, turf/landing_turf, backstory)
	var/datum/mind/player_mind = new /datum/mind(leader.key)
	player_mind.active = TRUE
	//if you want to add a fugitive with a special leader in the future, make this switch with the backstory
	var/mob/living/carbon/human/S = gear_fugitive(leader, landing_turf, backstory)
	var/obj/item/choice_beacon/augments/A = new(landing_turf)
	S.put_in_hands(A)
	new /obj/item/autosurgeon(landing_turf)

/datum/round_event/ghost_role/fugitives/proc/check_spawn_hunters(backstory, remaining_time)
	//if the emergency shuttle has been called, spawn hunters now to give them a chance
	if(remaining_time == 0 || !EMERGENCY_IDLE_OR_RECALLED)
		spawn_hunters(backstory)
		return
	addtimer(CALLBACK(src, PROC_REF(check_spawn_hunters), backstory, remaining_time - 1 MINUTES), 1 MINUTES)

/datum/round_event/ghost_role/fugitives/proc/spawn_hunters(backstory)
	var/list/candidates = SSpolling.poll_ghost_candidates("Do you wish to be considered for a group of [span_notice(backstory)]?", check_jobban = ROLE_FUGITIVE_HUNTER, alert_pic = /obj/machinery/sleeper, role_name_text = backstory)
	shuffle_inplace(candidates)

	var/datum/map_template/shuttle/hunter/ship
	switch(backstory)
		if(HUNTER_PACK_COPS)
			ship = new /datum/map_template/shuttle/hunter/space_cop
		if(HUNTER_PACK_RUSSIAN)
			ship = new /datum/map_template/shuttle/hunter/russian
		if(HUNTER_PACK_BOUNTY)
			ship = new /datum/map_template/shuttle/hunter/bounty
		if(HUNTER_PACK_PSYKER)
			ship = new /datum/map_template/shuttle/hunter/psyker

	var/x = rand(TRANSITIONEDGE,world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE,world.maxy - TRANSITIONEDGE - ship.height)
	var/z = SSmapping.empty_space.z_value
	var/turf/placement_turf = locate(x,y,z)
	if(!placement_turf)
		CRASH("Fugitive Hunters (Created from fugitive event) found no turf to load in")
	if(!ship.load(placement_turf))
		CRASH("Loading [backstory] ship failed!")

	for(var/turf/shuttle_turf in ship.get_affected_turfs(placement_turf))
		for(var/obj/effect/mob_spawn/ghost_role/human/fugitive/spawner in shuttle_turf)
			if(length(candidates))
				var/mob/our_candidate = candidates[1]
				var/mob/spawned_mob = spawner.create_from_ghost(our_candidate)
				candidates -= our_candidate
				notify_ghosts(
					"[spawner.prompt_name] has awoken: [spawned_mob]!",
					source = spawned_mob,
					header = "Come look!",
				)
			else
				notify_ghosts(
					"[spawner.prompt_name] spawner has been created!",
					source = spawner,
					header = "Spawn Here!",
				)

	var/list/announcement_text_list = list()
	var/announcement_title = ""
	switch(backstory)
		if(HUNTER_PACK_COPS)
			announcement_text_list += "Attention Crew of [GLOB.station_name], this is the Police. A wanted criminal has been reported taking refuge on your station."
			announcement_text_list += "We have a warrant from the SSC authorities to take them into custody. Officers have been dispatched to your location."
			announcement_text_list += "We demand your cooperation in bringing this criminal to justice."
			announcement_title += "Spacepol Command"
		if(HUNTER_PACK_RUSSIAN)
			announcement_text_list += "Zdraviya zhelaju, [GLOB.station_name] crew. We are coming to your station."
			announcement_text_list += "There is a criminal aboard. We will arrest them and return them to the gulag. That's good, yes?"
			announcement_title += "Russian Freighter"
		if(HUNTER_PACK_BOUNTY)
			announcement_text_list += "[GLOB.station_name]. One of our bounty marks has ended up on your station. We will be arriving to collect shortly."
			announcement_text_list += "Let's make this quick. If you don't want trouble, stay the hell out of our way."
			announcement_title += "Unregistered Signal"
		if(HUNTER_PACK_PSYKER)
			announcement_text_list += "HEY, CAN YOU HEAR US? We're coming to your station. There's a bad guy down there, really bad guy. We need to arrest them."
			announcement_text_list += "We're also offering fortune telling services out of the front door if you have paying customers."
			announcement_title += "Fortune-Telling Entertainment Shuttle"

	if(!length(announcement_text_list))
		announcement_text_list += "Unidentified ship detected near the station."
		stack_trace("Fugitive hunter announcement was unable to generate an announcement text based on backstory: [backstory]")

	if(!length(announcement_title))
		announcement_title += "Unknown Signal"
		stack_trace("Fugitive hunter announcement was unable to generate an announcement title based on backstory: [backstory]")

	priority_announce(jointext(announcement_text_list, " "), announcement_title)

#undef TEAM_BACKSTORY_SIZE
