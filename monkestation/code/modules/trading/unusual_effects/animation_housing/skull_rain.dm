/datum/component/particle_spewer/movement/skull_rain
	unusual_description = "spooky"
	icon_file = 'goon/icons/effects/particles.dmi'
	particle_state = "skull3"
	burst_amount = 4
	duration = 2 SECONDS
	random_bursts = TRUE
	spawn_interval = 0.4 SECONDS

/datum/component/particle_spewer/movement/skull_rain/animate_particle(obj/effect/abstract/particle/spawned)
	var/matrix/first = matrix(rand(1, 60), MATRIX_ROTATE)
	var/matrix/second = matrix()
	second.Turn(rand(-60, 60))

	var/chance = rand(1, 6)
	switch(chance)
		if(1 to 2)
			spawned.icon_state = "skull3"
		if(3 to 4)
			spawned.icon_state = "skull2"
		if(5 to 6)
			spawned.icon_state = "skull1"

	if(prob(35))
		spawned.layer = ABOVE_MOB_LAYER
	spawned.pixel_x += rand(-12, 12)
	spawned.pixel_y += rand(5, 10)
	spawned.transform = first
	spawned.alpha = 10

	animate(spawned, transform = second, time = 20, pixel_y = rand(-16, -12), alpha = 255, easing = BOUNCE_EASING)
	animate(time = duration, alpha = 1, easing = LINEAR_EASING)

	addtimer(CALLBACK(src, PROC_REF(delete_particle), spawned), duration)
