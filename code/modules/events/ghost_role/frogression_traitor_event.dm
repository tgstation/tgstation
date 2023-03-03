/datum/round_event_control/frogression_traitor
	name = "Spawn Frogression Traitor"
	typepath = /datum/round_event/ghost_role/frogression_traitor
	dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_ENTITIES
	description = "Spawns a frogression traitor."

/datum/round_event/ghost_role/frogression_traitor
	minimum_required = 1
	role_name = "frogression traitor"
	fakeable = FALSE

/datum/round_event/ghost_role/frogression_traitor/spawn_role()
	var/list/candidates = get_candidates(ROLE_ALIEN, ROLE_NIGHTMARE)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE

	if(!GLOB.xeno_spawn) //TODO spawn at a moisture trap
		return MAP_ERROR

	var/mob/living/basic/frog/syndifrog/frog = new(pick(GLOB.xeno_spawn))
	player_mind.transfer_to(frog)
	player_mind.set_assigned_role(SSjob.GetJobType(/datum/job/frogression_traitor))
	player_mind.special_role = ROLE_MORPH
	player_mind.add_antag_datum(/datum/antagonist/frogression_traitor)
	SEND_SOUND(frog, sound('sound/magic/mutate.ogg'))
	message_admins("[ADMIN_LOOKUPFLW(frog)] has been made into a frogression traitor by an event.")
	frog.log_message("was spawned as a frogression traitor by an event.", LOG_GAME)
	spawned_mobs += frog
	return SUCCESSFUL_SPAWN

