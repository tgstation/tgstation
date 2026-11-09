/datum/shuttle_event/simple_spawner/meteor
	spawning_list = list(/obj/effect/meteor)

/datum/shuttle_event/simple_spawner/meteor/post_spawn(atom/movable/spawnee)
	. = ..()
	ADD_TRAIT(spawnee, TRAIT_FREE_HYPERSPACE_MOVEMENT, INNATE_TRAIT)

/datum/shuttle_event/simple_spawner/meteor/spawn_movable(spawn_type)
	var/turf/spawn_turf = get_spawn_turf()
	//invert the dir cause we shoot in the opposite direction we're flying
	if(ispath(spawn_type, /obj/effect/meteor))
		post_spawn(new spawn_type (spawn_turf, get_edge_target_turf(spawn_turf, angle2dir(dir2angle(port.preferred_direction) - 180))))
	else //if you want to spawn some random garbage inbetween, go wild
		post_spawn(new spawn_type (get_spawn_turf()))

///Very weak meteors, but may very rarely actually hit the shuttle!
/datum/shuttle_event/simple_spawner/meteor/dust
	name = "Dust Meteors! (Mostly Safe)"
	event_probability = 2
	activation_fraction = 0.1

	spawn_probability_per_process = 100
	spawns_per_spawn = 5
	spawning_list = list(/obj/effect/meteor/dust = 1, /obj/effect/meteor/sand = 1)
	spawning_flags = SHUTTLE_EVENT_MISS_SHUTTLE | SHUTTLE_EVENT_HIT_SHUTTLE
	///We can, occassionally, hit the shuttle, but we dont do a lot of damage and should only do so pretty rarely
	var/hit_the_shuttle_chance = 1

/datum/shuttle_event/simple_spawner/meteor/dust/get_spawn_turf()
	return prob(hit_the_shuttle_chance) ? pick(spawning_turfs_hit) : pick(spawning_turfs_miss)

///Okay this spawns a lot of really bad meteors, but they never hit the shuttle so it's perfectly safe (unless you go outside lol)
/datum/shuttle_event/simple_spawner/meteor/safe
	name = "Various Meteors! (Safe)"
	event_probability = 5
	activation_fraction = 0.1

	spawn_probability_per_process = 100
	spawns_per_spawn = 6
	spawning_flags = SHUTTLE_EVENT_MISS_SHUTTLE
	spawning_list = list(/obj/effect/meteor/medium = 10, /obj/effect/meteor/big = 5, /obj/effect/meteor/flaming = 3, /obj/effect/meteor/cluster = 1,
	/obj/effect/meteor/irradiated = 3, /obj/effect/meteor/bluespace = 2)

/datum/shuttle_event/simple_spawner/meteor/dust/meaty
	name = "Meaty Meteors! (Mostly Safe)"
	spawning_list = list(/obj/effect/meteor/meaty = 1)
	spawning_flags = SHUTTLE_EVENT_MISS_SHUTTLE | SHUTTLE_EVENT_HIT_SHUTTLE

	event_probability = 0.1
	activation_fraction = 0.1
	spawn_probability_per_process = 100
	spawns_per_spawn = 3

	hit_the_shuttle_chance = 2
