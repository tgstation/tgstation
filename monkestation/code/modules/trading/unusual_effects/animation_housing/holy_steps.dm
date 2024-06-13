/datum/component/particle_spewer/movement/holy_steps
	unusual_description = "holy treads"
	duration = 5 SECONDS
	burst_amount = 25
	icon_file = 'goon/icons/effects/particles.dmi'
	particle_state = "starsmall"

/datum/component/particle_spewer/movement/holy_steps/animate_particle(obj/effect/abstract/particle/spawned)
	spawned.blend_mode = BLEND_ADD
	spawned.pixel_x += rand(-3,3)
	spawned.pixel_y += rand(-3,3)
	spawned.color = rgb(rand(1, 255), rand(1, 255), rand(1, 255))

	. = ..()

/datum/component/particle_spewer/movement/holy_steps/adjust_animate_steps()
	animate_holder.add_animation_step(list(transform = matrix(0.5, 0.5, MATRIX_SCALE), time = 0))
	animate_holder.add_animation_step(list(transform = "RANDOM", time = 0.4 SECONDS, pixel_y = "RANDOM", pixel_x = "RANDOM", easing = LINEAR_EASING))

	animate_holder.set_random_var(2, "transform", list(-90, 90))
	animate_holder.set_random_var(2, "pixel_x", list(-32, 32))
	animate_holder.set_random_var(2, "pixel_y", list(-32, 32))

	animate_holder.set_transform_type(2, MATRIX_ROTATE)
	animate_holder.add_animation_step(list(transform = "RANDOM", time = 0.5 SECONDS, pixel_y = -5, easing = LINEAR_EASING|EASE_OUT))

	animate_holder.set_random_var(3, "transform", list(-90, 90))
	animate_holder.set_parent_copy(3, "pixel_y")

	animate_holder.set_transform_type(3, MATRIX_ROTATE)

	animate_holder.add_animation_step(list(alpha = 0, time = duration))
