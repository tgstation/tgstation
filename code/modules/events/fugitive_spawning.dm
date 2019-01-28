/datum/round_event_control/fugitives
	name = "Spawn Fugitives"
	typepath = /datum/round_event/ghost_role/fugitives
	max_occurrences = 1
	min_players = 20
	earliest_start = 30 MINUTES //deadchat sink, lets not even consider it early on.

/datum/round_event/ghost_role/fugitives
	minimum_required = 1
	role_name = "fugitive"
	fakeable = FALSE

/datum/round_event/ghost_role/fugitives/spawn_role()
	var/list/candidates = get_candidates(ROLE_TRAITOR, null, ROLE_TRAITOR)
	if(candidates.len < 4)//reminder to set this after the backstory or enable backstory choices with the amount of candidates
		return NOT_ENOUGH_PLAYERS

	var/backstory = pick(list("prisoner", "cultists"))

	var/leader = pick_n_take(candidates)
	var/list/members = list()
	for(var/i in 1 to 3)
		members += pick_n_take(candidates)
	members += leader

	var/turf/landing_turf = pick(GLOB.xeno_spawn)
	if(!landing_turf)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	for(var/i in members)
		var/mob/dead/selected = i
		var/datum/mind/player_mind = new /datum/mind(selected.key)
		player_mind.active = TRUE

		if(selected == leader)
			switch(backstory)
				if("cultist")
					var/mob/camera/yalp_elor/yalp = new(landing_turf)
					player_mind.transfer_to(yalp)
					player_mind.assigned_role = "Yalp Elor"
					player_mind.special_role = "Old God"
					player_mind.add_antag_datum(/datum/antagonist/fugitive)
					for(var/cult in members)
						if(cult == leader)
							continue
						yalp.the_faithful += cult.mind //todo: find a way to switch this one to a mob or even better a team antag thing
		else
			var/mob/living/carbon/human/S = new(landing_turf)
			player_mind.transfer_to(S)
			player_mind.assigned_role = "Fugitive"
			player_mind.special_role = "Fugitive"
			player_mind.add_antag_datum(/datum/antagonist/fugitive) //they are not antagonists, but will show up roundend to see how they fared (and their origin)
			var/datum/antagonist/fugitive/fugitiveantag = player_mind.has_antag_datum(/datum/antagonist/fugitive)
			fugitiveantag.greet(backstory)

			switch(backstory)
				if("prisoner")
					L.fully_replace_character_name(null,"NTP #CC-0[rand(111,999)]") //same as the lavaland prisoner transport, but this time they are from CC, or CentCom
					S.equipOutfit(/datum/outfit/prisoner)
				if("cultist")
					S.equipOutfit(/datum/outfit/yalp_cultist)
		message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Fugitive by an event.")
		log_game("[key_name(S)] was spawned as a Fugitive by an event.")
		spawned_mobs += S

//after spawning
	playsound(src, 'sound/weapons/emitter.ogg', 50, 1)
	new /obj/item/storage/toolbox/mechanical(landing_turf) //so they can actually escape maint
	addtimer(CALLBACK(src, .proc/spawn_security), 6000) //10 minutes
	role_name = "fugitive hunter"
	return SUCCESSFUL_SPAWN


//security team gets called in after 10 minutes of prep to find the refugees
/datum/round_event/ghost_role/fugitives/proc/spawn_security()
	var/list/hunter_choices = list()
	var/list/candidates = get_candidates(ROLE_TRAITOR, null, ROLE_TRAITOR)
	if(candidates.len > 4)
		hunter_choices += "police"
	if(!hunter_choices.len)
		return //not enough people to add any kind of team
	var/hunter_team = pick(hunter_choices)
	var/leader = pick_n_take(candidates)
	var/list/members = list()
	for(var/i in 1 to 3)
		members += pick_n_take(candidates)
//wip
