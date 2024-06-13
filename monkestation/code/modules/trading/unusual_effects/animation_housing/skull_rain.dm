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

	. = ..()

/datum/component/particle_spewer/movement/skull_rain/adjust_animate_steps()
	animate_holder.add_animation_step(list(transform = "RANDOM", time = 2 SECONDS, pixel_y = "RANDOM", alpha = 255, easing = BOUNCE_EASING))
	animate_holder.set_random_var(1, "pixel_y", list(-16, -12))
	animate_holder.set_random_var(1, "transform", list(-60, 60))
	animate_holder.set_transform_type(1, MATRIX_ROTATE)

	animate_holder.add_animation_step(list(time = duration, alpha = 1, easing = LINEAR_EASING))
