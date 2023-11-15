/datum/component/particle_spewer/fire
	unusual_description = "flaming"
	duration = 2 SECONDS
	burst_amount = 3
	spawn_interval = 0.2 SECONDS
	particle_state = "1x1"

/datum/component/particle_spewer/fire/animate_particle(obj/effect/abstract/particle/spawned)
	spawned.blend_mode = BLEND_ADD
	spawned.pixel_x += rand(-6,6)
	spawned.pixel_y += rand(-4,4)

	spawned.add_filter("outline", 1, list(type = "outline", size = 1,  color = "#FF3300"))
	spawned.add_filter("bloom", 2 , list(type = "bloom", threshold = rgb(255,128,255), size = 3, offset = 4, alpha = 255))
	
	if(prob(35))
		spawned.layer = ABOVE_MOB_LAYER

	var/normal_x = rand(-4, 4) + spawned.pixel_x
	var/inverse_x = 0 - normal_x
	spawned.alpha = 0

	animate(spawned, alpha = 255,  time = 0.4 SECONDS, pixel_y = rand(6, 16) + spawned.pixel_y, pixel_x = normal_x, easing = LINEAR_EASING)
	animate(time = 0.5 SECONDS, alpha = 0, inverse_x , pixel_y = rand(6, 16) + spawned.pixel_y, easing = LINEAR_EASING|EASE_OUT)
	addtimer(CALLBACK(src, PROC_REF(delete_particle), spawned), duration)

/obj/item/debug_fire/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/particle_spewer/fire)
