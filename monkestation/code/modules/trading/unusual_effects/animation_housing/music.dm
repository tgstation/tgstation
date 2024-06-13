/datum/component/particle_spewer/shooting_star
	icon_file = 'goon/icons/effects/particles.dmi'
	particle_state = "beamed_eighth"

	unusual_description = "melody"
	duration = 2.5 SECONDS
	burst_amount = 2
	spawn_interval = 0.5 SECONDS
	offsets = FALSE

/datum/component/particle_spewer/shooting_star/animate_particle(obj/effect/abstract/particle/spawned)
	var/matrix/first = matrix()

	if(prob(30))
		spawned.icon_state = "eighth"
	if(prob(25))
		spawned.icon_state = "quarter"

	spawned.pixel_x += rand(-24, 24)
	spawned.pixel_y += rand(-6, 6)
	first.Turn(rand(-90, 90))
	spawned.transform = first

	. = ..()

/datum/component/particle_spewer/shooting_star/adjust_animate_steps()
	animate_holder.add_animation_step(list(transform = matrix(2, 2, MATRIX_SCALE), time = 0))
	animate_holder.set_transform_type(1, MATRIX_SCALE)

	animate_holder.add_animation_step(list(transform = "RANDOM", alpha = 220, time = 1))
	animate_holder.set_random_var(2, "transform", list(-90, 90))
	animate_holder.set_transform_type(2, MATRIX_ROTATE)

	animate_holder.add_animation_step(list(transform = matrix(), time = "RANDOM", pixel_y = 32, alpha = 1))
	animate_holder.set_parent_copy(3, "pixel_y")
	animate_holder.set_random_var(3, "time", list(20, 30))
