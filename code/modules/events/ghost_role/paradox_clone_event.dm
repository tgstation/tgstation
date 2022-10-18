/datum/round_event_control/paradox_clone
	name = "Spawn Paradox Clone"
	typepath = /datum/round_event/ghost_role/paradox_clone
	max_occurrences = 1
	min_players = 15
	earliest_start = 20 MINUTES //deadchat sink, lets not even consider it early on.
	category = EVENT_CATEGORY_INVASION
	description = "A time-space anomaly will occur and spawn a paradox clone somewhere on the station."

/datum/round_event/ghost_role/paradox_clone
	minimum_required = 1
	role_name = "paradox_clone"
	fakeable = FALSE

/datum/round_event/ghost_role/paradox_clone/spawn_role()
	var/list/candidates = get_candidates(ROLE_PARADOX_CLONE, ROLE_PARADOX_CLONE)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/list/possible_spawns = list()
	for(var/turf/X in GLOB.xeno_spawn)
		if(istype(X.loc, /area/station/maintenance))
			possible_spawns += X
	if(!possible_spawns.len)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	var/mob/dead/selected = pick(candidates)
	var/turf/landing_turf = pick(possible_spawns)
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE

	var/mob/living/carbon/human/S = new ((pick(possible_spawns)))
	player_mind.transfer_to(S)
	player_mind.set_assigned_role(SSjob.GetJobType(/datum/job/paradox_clone))
	player_mind.special_role = ROLE_PARADOX_CLONE
	player_mind.add_antag_datum(/datum/antagonist/paradox_clone)
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Paradox Clone by an event.")
	S.log_message("was spawned as a Paradox Clone by an event.", LOG_GAME)
	spawned_mobs += S
	playsound(S, 'sound/weapons/emitter.ogg', 50, TRUE)
	new /obj/item/storage/toolbox/mechanical(landing_turf)
	return SUCCESSFUL_SPAWN

/datum/round_event/paradox_clone_event/announce(fake)
	priority_announce("A time-space anomaly has been detected on the station, be aware of possible discrepancies.", "General Alert")


