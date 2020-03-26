/datum/round_event_control/handofgod
	name = "Spawn Hand of God"
	typepath = /datum/round_event/ghost_role/handofgod
	max_occurrences = 1
	weight = 10
	earliest_start = 20 MINUTES
	min_players = 20

/datum/round_event/ghost_role/handofgod
	minimum_required = 1
	role_name = "Hand of God"
	announceWhen = 10

/datum/round_event/ghost_role/handofgod/announce(fake)
	priority_announce("An easy meal for a happy home is headed to [station_name()], please stand-by.", "Lifesign Alert")

/datum/round_event/ghost_role/handofgod/spawn_role()
	var/list/candidates = get_candidates(ROLE_ALIEN, null, ROLE_ALIEN)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE

	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/carpspawn/C in GLOB.landmarks_list)
		spawn_locs += (C.loc)
	if(!spawn_locs.len)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	var/mob/living/simple_animal/hostile/handofgod/S = new (pick(spawn_locs))
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Hand of God"
	player_mind.special_role = "Hand of God"
	player_mind.add_antag_datum(/datum/antagonist/handofgod)
	playsound(S, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Hand of God by an event.")
	log_game("[key_name(S)] was spawned as a Hand of God by an event.")
	spawned_mobs += S
	return SUCCESSFUL_SPAWN
