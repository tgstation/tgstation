/datum/component/particle_spewer/fire
	unusual_description = "flaming"
	duration = 2 SECONDS
	burst_amount = 3
	spawn_interval = 0.2 SECONDS
	particle_state = "1x1"
	particle_blending = BLEND_ADD

/datum/component/particle_spewer/fire/animate_particle(obj/effect/abstract/particle/spawned)
	spawned.pixel_x += rand(-6,6)
	spawned.pixel_y += rand(-4,4)

	spawned.add_filter("outline", 1, list(type = "outline", size = 1,  color = "#FF3300"))
	spawned.add_filter("bloom", 2 , list(type = "bloom", threshold = rgb(255,128,255), size = 5, offset = 4, alpha = 255))

	if(prob(35))
		spawned.layer = ABOVE_MOB_LAYER

	spawned.alpha = 130

	. = ..()

/datum/component/particle_spewer/fire/adjust_animate_steps()
	animate_holder.add_animation_step(list(alpha = 255, time = 0.4 SECONDS, pixel_y = "RANDOM", pixel_x = "RANDOM", easing = LINEAR_EASING))
	animate_holder.set_random_var(1, "pixel_y", list(6, 16))
	animate_holder.set_parent_copy(1, "pixel_y")
	animate_holder.set_random_var(1, "pixel_x", list(-4, 4))
	animate_holder.set_parent_copy(1, "pixel_x")

	animate_holder.add_animation_step(list(alpha = 0, time = 0.5 SECONDS, pixel_x = "RANDOM", pixel_y = "RANDOM", easing = LINEAR_EASING|EASE_OUT))
	animate_holder.set_random_var(2, "pixel_y", list(6, 16))
	animate_holder.set_random_var(2, "pixel_x", list(-4, 4))
	animate_holder.set_parent_copy(2, "pixel_y")
	animate_holder.set_parent_copy(2, "pixel_x", FALSE)


/obj/item/debug_fire/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/particle_spewer/fire)
