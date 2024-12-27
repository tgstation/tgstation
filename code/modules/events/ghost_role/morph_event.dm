/datum/round_event_control/morph
	name = "Spawn Morph"
	typepath = /datum/round_event/ghost_role/morph
	weight = 0
	max_occurrences = 1
	category = EVENT_CATEGORY_ENTITIES
	description = "Spawns a hungry shapeshifting blobby creature."
	min_wizard_trigger_potency = 4
	max_wizard_trigger_potency = 7

/datum/round_event/ghost_role/morph
	minimum_required = 1
	role_name = "morphling"

/datum/round_event/ghost_role/morph/spawn_role()
	var/mob/chosen_one = SSpolling.poll_ghost_candidates(check_jobban = ROLE_ALIEN, role = ROLE_ALIEN, alert_pic = /mob/living/basic/morph, role_name_text = "morph", amount_to_pick = 1)
	if(isnull(chosen_one))
		return NOT_ENOUGH_PLAYERS
	var/datum/mind/player_mind = new /datum/mind(chosen_one.key)
	player_mind.active = TRUE

	var/turf/spawn_loc = find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = FALSE)
	if(isnull(spawn_loc))
		return MAP_ERROR

	var/mob/living/basic/morph/corpus_accipientis = new(spawn_loc)
	player_mind.transfer_to(corpus_accipientis)
	player_mind.set_assigned_role(SSjob.get_job_type(/datum/job/morph))
	player_mind.special_role = ROLE_MORPH
	player_mind.add_antag_datum(/datum/antagonist/morph)
	SEND_SOUND(corpus_accipientis, sound('sound/effects/magic/mutate.ogg'))
	message_admins("[ADMIN_LOOKUPFLW(corpus_accipientis)] has been made into a morph by an event.")
	corpus_accipientis.log_message("was spawned as a morph by an event.", LOG_GAME)
	spawned_mobs += corpus_accipientis
	return SUCCESSFUL_SPAWN
