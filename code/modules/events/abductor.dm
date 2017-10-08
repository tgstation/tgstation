/datum/round_event_control/abductor
	name = "Abductors"
	typepath = /datum/round_event/ghost_role/abductor
	weight = 10
	max_occurrences = 1
	min_players = 20
	gamemode_blacklist = list("nuclear","wizard","revolution","abduction")

/datum/round_event/ghost_role/abductor
	minimum_required = 2
	role_name = "abductor team"

/datum/round_event/ghost_role/abductor/spawn_role()
	var/list/mob/dead/observer/candidates = get_candidates("abductor", null, ROLE_ABDUCTOR)

	if(candidates.len < 2)
		return NOT_ENOUGH_PLAYERS

	var/datum/game_mode/abduction/GM
	if(SSticker.mode.config_tag == "abduction")
		GM = SSticker.mode
	else
		GM = new

	var/mob/living/carbon/human/agent = makeBody(pick_n_take(candidates))
	var/mob/living/carbon/human/scientist = makeBody(pick_n_take(candidates))

	GM.post_setup_team(GM.make_abductor_team(agent.mind, scientist.mind))

	spawned_mobs += list(agent, scientist)
	return SUCCESSFUL_SPAWN
