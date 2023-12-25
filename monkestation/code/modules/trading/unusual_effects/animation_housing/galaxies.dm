/datum/component/particle_spewer/galaxies
	unusual_description = "galactic"
	duration = 5 SECONDS
	spawn_interval = 0.5 SECONDS
	burst_amount = 6
	particle_state = "snow_small"


/datum/component/particle_spewer/galaxies/animate_particle(obj/effect/abstract/particle/spawned)
	var/can_be_shooting = TRUE
	if(prob(5))
		spawned.icon_state = "moon"
		can_be_shooting = FALSE

	if(prob(5) && can_be_shooting)
		spawned.icon_state = "ringed_planet"
		can_be_shooting = FALSE

	spawned.pixel_x += rand(-16,16)
	spawned.pixel_y += rand(-12,4)

	if(prob(45) && can_be_shooting)
		spawned.layer = ABOVE_MOB_LAYER

	animate(spawned, alpha = 0, time = duration)
	if(prob(33) && can_be_shooting)
		animate(spawned, pixel_y = spawned.pixel_y + rand(-6, 6), pixel_x = spawned.pixel_x + rand(-16, 16), time = 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(delete_particle), spawned), duration)
