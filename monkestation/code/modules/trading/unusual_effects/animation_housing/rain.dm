/datum/component/particle_spewer/rain
	unusual_description = "gloomy"
	icon_file = 'monkestation/code/modules/outdoors/icons/effects/particles/particle.dmi'
	particle_state = "drop"
	duration = 0.9 SECONDS
	spawn_interval = 0.1 SECONDS
	burst_amount = 3

/datum/component/particle_spewer/rain/animate_particle(obj/effect/abstract/particle/spawned)
	if(prob(45))
		spawned.layer = ABOVE_MOB_LAYER
	spawned.pixel_x += rand(-14, 14)
	spawned.pixel_y += rand(19, 25)
	spawned.alpha = 20
	spawned.color = pick(list(COLOR_BLUE_GRAY, COLOR_BLUE_LIGHT, COLOR_CARP_BLUE))

	. = ..()

/datum/component/particle_spewer/rain/adjust_animate_steps()
	animate_holder.add_animation_step(list(time = 0.5 SECONDS, alpha = 255))
	animate_holder.add_animation_step(list(time = 0.8 SECONDS, pixel_y = "RANDOM", easing = LINEAR_EASING))
	animate_holder.set_random_var(2, "pixel_y", list(-20, -12))
