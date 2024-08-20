/datum/round_event_control/plague_rat
	name = "Spawn Plague Rats"
	typepath = /datum/round_event/ghost_role/plague_rat
	weight = 7
	max_occurrences = 1
	track = EVENT_TRACK_MAJOR
	min_players = 30 //monke edit: 20 to 30
	earliest_start = 30 MINUTES //monke edit: 20 to 60
	//dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_ENTITIES
	description = "Spawns a horde of plague rats."
	min_wizard_trigger_potency = 6
	max_wizard_trigger_potency = 7

/datum/round_event/ghost_role/plague_rat
	minimum_required = 1
	role_name = "Plague Rat"

/datum/round_event/ghost_role/plague_rat/spawn_role()
	var/list/candidates = SSpolling.poll_ghost_candidates(check_jobban = ROLE_PLAGUERAT, role = ROLE_PLAGUERAT, alert_pic = /mob/living/basic/mouse/plague, amount_to_pick = 4)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	for(var/mob/dead/selected in candidates)
		var/key = selected.key
		var/mob/living/basic/mouse/plague/dragon = new
		dragon.key = key
		dragon.mind.special_role = ROLE_PLAGUERAT
		dragon.mind.add_antag_datum(/datum/antagonist/plague_rat)
		playsound(dragon, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
		message_admins("[ADMIN_LOOKUPFLW(dragon)] has been made into a plague rat by an event.")
		dragon.log_message("was spawned as a plague rat by an event.", LOG_GAME)
		dragon.forceMove()
		spawned_mobs += dragon

	return SUCCESSFUL_SPAWN
