/datum/round_event_control/wizard/magicarp //these fish is loaded
	name = "Magicarp"
	weight = 1
	typepath = /datum/round_event/wizard/magicarp
	max_occurrences = 1
	earliest_start = 0 MINUTES
	description = "Summons a school of carps with magic projectiles."

/datum/round_event/wizard/magicarp
	announce_when = 3
	start_when = 50
	/// Whether we have created a point of interest for ghosts already
	var/announced_to_ghosts = FALSE

/datum/round_event/wizard/magicarp/setup()
	start_when = rand(40, 60)

/datum/round_event/wizard/magicarp/announce(fake)
	priority_announce("Unknown magical entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")

/datum/round_event/wizard/magicarp/start()
	var/mob/living/basic/carp/magic/fish
	for(var/obj/effect/landmark/carpspawn/spawn_point in GLOB.landmarks_list)
		if(prob(5))
			fish = new /mob/living/basic/carp/magic/chaos(spawn_point.loc)
			fish_announce(fish) //Prefer to announce the more dangerous kind
		else
			fish = new(spawn_point.loc)

		var/turf/path_mid_point = get_safe_random_station_turf(z_level = fish.z)
		var/turf/path_end_point = get_edge_target_turf(fish, get_dir(fish, path_mid_point))
		if (!path_mid_point || !path_end_point)
			continue
		fish.ai_controller.blackboard[BB_CARP_MIGRATION_PATH] = list(WEAKREF(path_mid_point), WEAKREF(path_end_point))

	fish_announce(fish)

/// Advertise the most relevant fish to ghosts
/datum/round_event/wizard/magicarp/proc/fish_announce(atom/fish)
	if (!announced_to_ghosts)
		announce_to_ghosts(fish) //Only anounce the first fish
		announced_to_ghosts = TRUE
