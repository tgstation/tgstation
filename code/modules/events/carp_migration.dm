/datum/round_event_control/carp_migration
	name = "Carp Migration"
	typepath = /datum/round_event/carp_migration
	weight = 15
	min_players = 2
	earliest_start = 10 MINUTES
	max_occurrences = 6
	category = EVENT_CATEGORY_ENTITIES
	description = "Summons a school of space carp."

/datum/round_event_control/carp_migration/New()
	. = ..()
	if(!HAS_TRAIT(SSstation, STATION_TRAIT_CARP_INFESTATION))
		return
	weight *= 3
	max_occurrences *= 2
	earliest_start *= 0.5

/datum/round_event/carp_migration
	announce_when = 3
	start_when = 50
	var/hasAnnounced = FALSE

/datum/round_event/carp_migration/setup()
	start_when = rand(40, 60)

/datum/round_event/carp_migration/announce(fake)
	priority_announce("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")

/datum/round_event/carp_migration/start()
	var/mob/living/basic/carp/fish
	for(var/obj/effect/landmark/carpspawn/spawn_point in GLOB.landmarks_list)
		if(prob(95))
			fish = new (spawn_point.loc)
		else
			fish = new /mob/living/basic/carp/mega(spawn_point.loc)
			fishannounce(fish) //Prefer to announce the megacarps over the regular fishies

		var/turf/path_mid_point = get_safe_random_station_turf(z_level = fish.z)
		var/turf/path_end_point = get_edge_target_turf(fish, get_dir(fish, path_mid_point))
		if (!path_mid_point || !path_end_point)
			continue
		fish.ai_controller.blackboard[BB_CARP_MIGRATION_PATH] = list(WEAKREF(path_mid_point), WEAKREF(path_end_point))

	fishannounce(fish)

/datum/round_event/carp_migration/proc/fishannounce(atom/fish)
	if (!hasAnnounced)
		announce_to_ghosts(fish) //Only anounce the first fish
		hasAnnounced = TRUE
