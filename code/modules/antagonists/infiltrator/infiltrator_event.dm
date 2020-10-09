/datum/round_event_control/infiltrator
	name = "Syndicate Infiltration"
	typepath = /datum/round_event/ghost_role/infiltrator
	weight = 6
	max_occurrences = 2
	min_players = 1
	earliest_start = 15 MINUTES
	gamemode_blacklist = list("nuclear")

/datum/round_event/ghost_role/infiltrator
	minimum_required = 1
	role_name = "syndicate infiltrator"
	fakeable = FALSE
	var/maximum_infiltrators = 2

/datum/round_event/ghost_role/infiltrator/spawn_role()
	var/list/candidates = get_candidates(ROLE_TRAITOR, null, ROLE_TRAITOR)
	var/list/members = list()
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/chance = pickweight(list(1 = 3, 2 = 2, 3 = 1))
	maximum_infiltrators = pick(chance)

	for(var/i in 1 to maximum_infiltrators)
		members += pick_n_take(candidates)

	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/carpspawn/L in GLOB.landmarks_list)
		spawn_locs += L.loc
	if(!spawn_locs.len)
		return MAP_ERROR

	for(var/mob/dead/selected in members)
		var/mob/living/carbon/human/infiltrator = spawn_t(selected, spawn_locs)
		spawned_mobs += infiltrator

	return SUCCESSFUL_SPAWN

/datum/round_event/ghost_role/infiltrator/proc/spawn_t(mob/dead/selected, list/spawn_locs)
	var/datum/mind/Mind = new /datum/mind(selected.key)
	var/mob/living/carbon/human/infiltrator = new(pick(spawn_locs))
	Mind.active = TRUE
	var/datum/preferences/A = new
	A.copy_to(infiltrator)
	infiltrator.dna.update_dna_identity()
	Mind.transfer_to(infiltrator)
	Mind.add_antag_datum(/datum/antagonist/traitor/infiltrator/event)

	message_admins("[ADMIN_LOOKUPFLW(infiltrator)] has been made into syndicate infiltrator by an event.")
	log_game("[key_name(infiltrator)] was spawned as a syndicate infiltrator by an event.")
	spawned_mobs += infiltrator
