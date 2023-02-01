/datum/round_event_control/abductor
	name = "Abductors"
	typepath = /datum/round_event/ghost_role/abductor
	weight = 10
	max_occurrences = 1
	min_players = 20
	dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_INVASION
	description = "One or more abductor teams spawns, and they plan to experiment on the crew."

/datum/round_event/ghost_role/abductor
	minimum_required = 2
	role_name = "abductor team"
	fakeable = FALSE //Nothing to fake here

/datum/round_event/ghost_role/abductor/spawn_role()
	var/list/mob/dead/observer/candidates = get_candidates(ROLE_ABDUCTOR, ROLE_ABDUCTOR)

	if(candidates.len < 2)
		return NOT_ENOUGH_PLAYERS

	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_ABDUCTOR_SHIPS)
	var/mob/living/carbon/human/agent = make_body(pick_n_take(candidates))
	var/mob/living/carbon/human/scientist = make_body(pick_n_take(candidates))

	var/datum/team/abductor_team/T = new
	if(T.team_number > ABDUCTOR_MAX_TEAMS)
		return MAP_ERROR

	scientist.log_message("has been selected as [T.name] abductor scientist.", LOG_GAME)
	agent.log_message("has been selected as [T.name] abductor agent.", LOG_GAME)

	scientist.mind.add_antag_datum(/datum/antagonist/abductor/scientist, T)
	agent.mind.add_antag_datum(/datum/antagonist/abductor/agent, T)

	spawned_mobs += list(agent, scientist)

	return SUCCESSFUL_SPAWN
