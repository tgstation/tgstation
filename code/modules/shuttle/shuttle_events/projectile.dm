/// Spawn projectiles towards the shuttle
/datum/shuttle_event/simple_spawner/projectile
	var/angle_spread = 0

/datum/shuttle_event/simple_spawner/projectile/post_spawn(atom/movable/spawnee)
	. = ..()

	if(isprojectile(spawnee))
		var/obj/projectile/pew = spawnee
		var/angle = angle2dir(dir2angle(port.preferred_direction) - 180) + rand(-angle_spread, angle_spread)
		pew.fire()
