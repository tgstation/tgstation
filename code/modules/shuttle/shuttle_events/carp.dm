///CARPTIDE! CARPTIDE! CARPTIDE! A swarm of carp will pass by and through the shuttle, including consequences of carp going through the shuttle
/datum/shuttle_event/simple_spawner/carp
	name = "Carp Nest! (Very Dangerous!)"
	event_probability = 0.4
	activation_fraction = 0.2

	spawning_list = list(/mob/living/basic/carp = 12, /mob/living/basic/carp/mega = 3)
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE | SHUTTLE_EVENT_MISS_SHUTTLE
	spawn_probability_per_process = 20

	remove_from_list_when_spawned = TRUE
	self_destruct_when_empty = TRUE

/datum/shuttle_event/simple_spawner/carp/post_spawn(mob/living/basic/carp/carpee)
	. = ..()
	//Give the carp the goal to migrate in a straight line so they dont just idle in hyperspace
	carpee.migrate_to(list(WEAKREF(get_edge_target_turf(carpee.loc, angle2dir(dir2angle(port.preferred_direction) - 180)))))

///Spawn a bunch of friendly carp to view from inside the shuttle! May occassionally pass through and nibble some windows, but are otherwise pretty harmless
/datum/shuttle_event/simple_spawner/carp/friendly
	name = "Passive Carp Nest! (Mostly Harmless!)"
	event_probability = 3
	activation_fraction = 0.1

	spawning_list = list(/mob/living/basic/carp/passive = 1)
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE | SHUTTLE_EVENT_MISS_SHUTTLE
	spawns_per_spawn = 2
	spawn_probability_per_process = 100

	remove_from_list_when_spawned = FALSE

	///Chance we hit the shuttle, instead of flying past it (most carp will go through anyway, and we dont want this to be too annoying to take away from the majesty)
	var/hit_the_shuttle_chance = 1

/datum/shuttle_event/simple_spawner/carp/friendly/get_spawn_turf()
	return prob(hit_the_shuttle_chance) ? pick(spawning_turfs_hit) : pick(spawning_turfs_miss)

///Same as /friendly, but we only go through the shuttle, MUHAHAHAHAHAHA!! They dont actually harm anyone, but itll be a clusterfuck of confusion
/datum/shuttle_event/simple_spawner/carp/friendly_but_no_personal_space
	name = "Comfortable Carp Nest going through the shuttle! (Extremely annoying and confusing!)"
	event_probability = 0
	activation_fraction = 0.5

	spawning_list = list(/mob/living/basic/carp/passive = 1)
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE
	spawns_per_spawn = 2
	spawn_probability_per_process = 100

	remove_from_list_when_spawned = FALSE

///CARPTIDE! CARPTIDE! CARPTIDE! Magical carp will attack the shuttle!
/datum/shuttle_event/simple_spawner/carp/magic
	name = "Magical Carp Nest! (Very Dangerous!)"
	spawning_list = list(/mob/living/basic/carp/magic = 12, /mob/living/basic/carp/magic/chaos = 3)
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE | SHUTTLE_EVENT_MISS_SHUTTLE

	event_probability = 0
	activation_fraction = 0.2
	spawn_probability_per_process = 20

	remove_from_list_when_spawned = TRUE
	self_destruct_when_empty = TRUE

/// Spawns some player controlled fire sharks
/datum/shuttle_event/simple_spawner/player_controlled/fire_shark
	name = "Three player controlled fire sharks! (Dangerous!)"
	spawning_list = list(/mob/living/basic/heretic_summon/fire_shark = 3)
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE

	event_probability = 0
	activation_fraction = 0.2
	spawn_probability_per_process = 100
	spawns_per_spawn = 3

	spawn_anyway_if_no_player = FALSE
	ghost_alert_string = "Would you like to be a fire shark attacking the shuttle?"
	remove_from_list_when_spawned = TRUE
	self_destruct_when_empty = TRUE

	role_type = ROLE_SENTIENCE
