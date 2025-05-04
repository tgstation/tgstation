/datum/round_event_control/voidwalker
	name = "Spawn Voidwalker"
	typepath = /datum/round_event/ghost_role/voidwalker
	max_occurrences = 1
	min_players = 40
	dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_ENTITIES
	description = "Spawns a voidwalker, who will terrorize anyone near space."
	min_wizard_trigger_potency = 6
	max_wizard_trigger_potency = 7

/datum/round_event_control/voidwalker/can_spawn_event(players_amt, allow_magic)
	var/turf/space_turf = find_space_spawn()
	// Space only antag and will die on planetary gravity.
	if(SSmapping.is_planetary() || !space_turf)
		return FALSE
	. = ..()

/datum/round_event/ghost_role/voidwalker
	minimum_required = 1
	role_name = "voidwalker"
	fakeable = FALSE

/datum/round_event/ghost_role/voidwalker/spawn_role()
	var/mob/applicant = SSpolling.poll_ghost_candidates(check_jobban = ROLE_ALIEN, role = ROLE_VOIDWALKER, role_name_text = role_name, amount_to_pick = 1)
	if(isnull(applicant))
		return NOT_ENOUGH_PLAYERS

	var/datum/mind/player_mind = new /datum/mind(applicant.key)
	player_mind.active = TRUE

	var/mob/living/carbon/human/voidwalker = new (find_space_spawn())
	player_mind.transfer_to(voidwalker)
	player_mind.set_assigned_role(SSjob.get_job_type(/datum/job/voidwalker))
	player_mind.special_role = ROLE_VOIDWALKER
	player_mind.add_antag_datum(/datum/antagonist/voidwalker) //Applies species on antag datum gain.

	playsound(voidwalker, 'sound/effects/magic/ethereal_exit.ogg', 50, TRUE, -1)
	message_admins("[ADMIN_LOOKUPFLW(voidwalker)] has been made into a Voidwalker by a random event.")
	voidwalker.log_message("was spawned as a Voidwalker by an event.", LOG_GAME)
	spawned_mobs += voidwalker
	return SUCCESSFUL_SPAWN
