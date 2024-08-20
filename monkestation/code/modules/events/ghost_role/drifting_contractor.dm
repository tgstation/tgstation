/datum/round_event_control/contractor
	name = "Drifting Contractor"
	typepath = /datum/round_event/ghost_role/contractor
	weight = 8
	max_occurrences = 2
	min_players = 20

	category = EVENT_CATEGORY_SPACE
	description = "Spawns a contractor in space near the station."
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_OUTSIDER_ANTAG, TAG_SPACE, TAG_COMBAT)
	checks_antag_cap = TRUE

/datum/round_event/ghost_role/contractor
	minimum_required = 1
	role_name = "Drifting Contractor"

/datum/round_event/ghost_role/contractor/spawn_role()
	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		"Do you want to play as a drifting contractor?",
		check_jobban = ROLE_DRIFTING_CONTRACTOR,
		role = ROLE_DRIFTING_CONTRACTOR,
		poll_time = 20 SECONDS,
		alert_pic = /datum/antagonist/traitor/contractor,
		role_name_text = "drifting contractor"
	)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick(candidates)

	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/carpspawn/carp in GLOB.landmarks_list)
		spawn_locs += carp.loc
	if(!length(spawn_locs))
		return MAP_ERROR

	var/mob/living/carbon/human/operative = new(pick(spawn_locs))
	operative.randomize_human_appearance(~RANDOMIZE_SPECIES)
	operative.dna.update_dna_identity()
	var/datum/mind/mind = new /datum/mind(selected.key)
	mind.set_assigned_role(SSjob.GetJobType(/datum/job/drifting_contractor))
	mind.special_role = ROLE_DRIFTING_CONTRACTOR
	mind.active = TRUE
	mind.transfer_to(operative)
	mind.add_antag_datum(/datum/antagonist/traitor/contractor)
	operative.fully_heal() //this is a lag issue so this is the best I got

	message_admins("[ADMIN_LOOKUPFLW(operative)] has been made into a [src] by an event.")
	log_game("[key_name(operative)] was spawned as a [src] by an event.")
	spawned_mobs += operative
	return SUCCESSFUL_SPAWN
