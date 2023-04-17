/datum/round_event_control/slaughter
	name = "Spawn Slaughter Demon"
	typepath = /datum/round_event/ghost_role/slaughter
	weight = 1 //Very rare
	max_occurrences = 1
	earliest_start = 1 HOURS
	min_players = 20
	dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_ENTITIES
	description = "Spawns a slaughter demon, to hunt by travelling through pools of blood."
	min_wizard_trigger_potency = 6
	max_wizard_trigger_potency = 7

/datum/round_event/ghost_role/slaughter
	minimum_required = 1
	role_name = "slaughter demon"

/datum/round_event/ghost_role/slaughter/spawn_role()
	var/list/candidates = get_candidates(ROLE_ALIEN, ROLE_ALIEN)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick_n_take(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE

	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/carpspawn/L in GLOB.landmarks_list)
		if(isturf(L.loc))
			spawn_locs += L.loc

	if(!spawn_locs)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	var/turf/chosen = pick(spawn_locs)
	var/mob/living/simple_animal/hostile/imp/slaughter/S = new(chosen)
	new /obj/effect/dummy/phased_mob(chosen, S)

	player_mind.transfer_to(S)
	player_mind.set_assigned_role(SSjob.GetJobType(/datum/job/slaughter_demon))
	player_mind.special_role = ROLE_SLAUGHTER_DEMON
	player_mind.add_antag_datum(/datum/antagonist/slaughter)
	to_chat(S, span_bold("You are currently not currently in the same plane of existence as the station. \
		Use your Blood Crawl ability near a pool of blood to manifest and wreak havoc."))
	SEND_SOUND(S, 'sound/magic/demon_dies.ogg')
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a slaughter demon by an event.")
	S.log_message("was spawned as a slaughter demon by an event.", LOG_GAME)
	spawned_mobs += S
	return SUCCESSFUL_SPAWN
