/datum/round_event_control/slasher
	name = "Slasher"
	typepath = /datum/round_event/ghost_role/slasher
	weight = 0 // for now, disabled. prev weight of 14. max occurrances set to 0 to disable the storyteller from running the event. can still be manually done by admins as requested.
	max_occurrences = 0
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_SPOOKY, TAG_COMBAT, TAG_EXTERNAL)
	checks_antag_cap = TRUE

/datum/round_event/ghost_role/slasher
	minimum_required = 1
	role_name = "Slasher"
	fakeable = FALSE

/datum/round_event/ghost_role/slasher/spawn_role()
	var/list/candidates = SSpolling.poll_ghost_candidates(
		question = "Do you want to play as a Slasher?",
		role = ROLE_SLASHER,
		check_jobban = ROLE_SLASHER,
		poll_time = 20 SECONDS,
		alert_pic = /datum/antagonist/slasher,
		role_name_text = "slasher"
	)
	var/turf/spawn_loc = find_safe_turf()//Used for the Drop Pod type of spawn

	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick_n_take(candidates)
	var/mob/living/carbon/human/slasher = new(spawn_loc) //This is to catch errors by just giving them a location in general.

	slasher.dna.update_dna_identity()
	var/datum/mind/Mind = new /datum/mind(selected.key)
	Mind.special_role = "Slasher"
	Mind.active = 1
	Mind.transfer_to(slasher)
	Mind.add_antag_datum(/datum/antagonist/slasher)


	message_admins("[ADMIN_LOOKUPFLW(slasher)] has been made into Slasher.")
	log_game("[key_name(slasher)] was spawned as Slasher by an event.")
	spawned_mobs += slasher
	return SUCCESSFUL_SPAWN
