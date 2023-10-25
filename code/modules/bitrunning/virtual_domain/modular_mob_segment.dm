#define SPAWN_ALWAYS 100
#define SPAWN_LIKELY 85
#define SPAWN_UNLIKELY 35
#define SPAWN_RARE 10

/datum/modular_mob_segment
	/// Set this to false if you want explicitly what's in the list to spawn
	var/randomized = TRUE
	/// Spawn a random amount from the list
	var/pick_random_of = 0
	/// The list of mobs to spawn
	var/list/mob/living/mobs = list()
	/// Chance this will spawn (1 - 100)
	var/probability = SPAWN_LIKELY

/// Spawns mobs in a circle around the location
/datum/modular_mob_segment/proc/spawn_mobs(turf/location)
	if(!prob(probability))
		return

	var/spawned
	var/current_distance = 1
	var/current_index = 1

	var/total_amount
	if(pick_random_of > 0)
		total_amount = pick_random_of
	else
		if(!randomized)
			total_amount = length(mobs)
		else
			total_amount = rand(1, 6)

	shuffle_inplace(mobs)

	for(var/index in 1 to total_amount)
		spawned = FALSE

		while(!spawned)
			if(current_distance > 10)
				CRASH("Could not find a spot to spawn a modular mob segment!")

			for(var/turf/open/spot in view(current_distance, location))
				if(spot.is_blocked_turf())
					continue

				var/path
				if(randomized)
					path = pick(mobs)
				else
					path = mobs[current_index]
					current_index++

				new path(spot)
				spawned = TRUE
				break

			current_distance++

// Some generic mob segments. If you want to add generic ones for any map, add them here

/datum/modular_mob_segment/gondolas
	pick_random_of = 3
	mobs = list(
		/mob/living/simple_animal/pet/gondola,
	)

/datum/modular_mob_segment/corgis
	pick_random_of = 2
	mobs = list(
		/mob/living/basic/pet/dog/corgi,
	)

/datum/modular_mob_segment/monkeys
	pick_random_of = 3
	mobs = list(
		/mob/living/carbon/human/species/monkey,
	)

/datum/modular_mob_segment/syndicate_team
	pick_random_of = 3
	mobs = list(
		/mob/living/basic/trooper/syndicate/ranged,
		/mob/living/basic/trooper/syndicate/melee,
	)

/datum/modular_mob_segment/syndicate_elite
	pick_random_of = 3
	mobs = list(
		/mob/living/basic/trooper/syndicate/melee/sword/space/stormtrooper,
		/mob/living/basic/trooper/syndicate/ranged/space/stormtrooper,
	)

/datum/modular_mob_segment/bears
	pick_random_of = 2
	mobs = list(
		/mob/living/basic/bear,
	)

/datum/modular_mob_segment/bees
	randomized = FALSE
	mobs = list(
		/mob/living/basic/bee,
		/mob/living/basic/bee,
		/mob/living/basic/bee,
		/mob/living/basic/bee,
		/mob/living/basic/bee/queen,
	)

/datum/modular_mob_segment/bees_toxic
	mobs = list(
		/mob/living/basic/bee/toxin,
	)

/datum/modular_mob_segment/blob_spores
	mobs = list(
		/mob/living/basic/blob_minion,
	)

/datum/modular_mob_segment/carps
	mobs = list(
		/mob/living/basic/carp,
	)

/datum/modular_mob_segment/hivebots
	mobs = list(
		/mob/living/basic/hivebot,
		/mob/living/basic/hivebot/range,
	)

/datum/modular_mob_segment/hivebots_strong
	pick_random_of = 3
	mobs = list(
		/mob/living/basic/hivebot/strong,
		/mob/living/basic/hivebot/range,
	)

/datum/modular_mob_segment/lavaland_assorted
	pick_random_of = 3
	mobs = list(
		/mob/living/basic/mining/basilisk,
		/mob/living/basic/mining/goliath,
		/mob/living/basic/mining/brimdemon,
		/mob/living/basic/mining/lobstrosity,
	)

/datum/modular_mob_segment/spiders
	mobs = list(
		/mob/living/basic/spider/giant/ambush,
		/mob/living/basic/spider/giant/hunter,
		/mob/living/basic/spider/giant/nurse,
		/mob/living/basic/spider/giant/tarantula,
		/mob/living/basic/spider/giant/midwife,
	)

/datum/modular_mob_segment/spider/threatening
	pick_random_of = 6

/datum/modular_mob_segment/venus_trap
	mobs = list(
		/mob/living/basic/venus_human_trap,
	)

/datum/modular_mob_segment/xenos
	mobs = list(
		/mob/living/carbon/alien/adult/hunter,
		/mob/living/carbon/alien/adult/sentinel,
		/mob/living/carbon/alien/adult/drone,

	)

#undef SPAWN_ALWAYS
#undef SPAWN_LIKELY
#undef SPAWN_UNLIKELY
#undef SPAWN_RARE
