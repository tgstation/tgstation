/// Spawn projectiles towards the shuttle
/datum/shuttle_event/simple_spawner/projectile
	/// Spread of the fired projectiles, to add some flair to it
	var/angle_spread = 0

/datum/shuttle_event/simple_spawner/projectile/post_spawn(atom/movable/spawnee)
	. = ..()

	if(isprojectile(spawnee))
		var/obj/projectile/pew = spawnee
		var/angle = dir2angle(REVERSE_DIR(port.preferred_direction)) + rand(-angle_spread, angle_spread)
		pew.fire(angle)

/datum/shuttle_event/simple_spawner/projectile/fireball //bap bap bapaba bap
	name = "Fireball Burst (Surprisingly safe!)"
	activation_fraction = 0.5 // this doesn't matter for hijack events but just in case its forced

	spawning_list = list(/obj/projectile/magic/fireball = 1)
	angle_spread = 10
	spawns_per_spawn = 10
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE | SHUTTLE_EVENT_HIT_SHUTTLE
	spawn_probability_per_process = 2
	self_destruct_when_empty = TRUE
