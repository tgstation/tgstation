/datum/component/particle_spewer/confetti
	unusual_description = "partytime"
	duration = 2 SECONDS
	burst_amount = 5
	particle_blending = BLEND_ADD
	spawn_interval = 1 SECONDS

/datum/component/particle_spewer/confetti/animate_particle(obj/effect/abstract/particle/spawned)
	var/matrix/first = matrix()
	var/matrix/second = matrix()

	spawned.pixel_x += rand(-3,3)
	spawned.pixel_y += rand(-3,3)

	first.Turn(rand(-90, 90))
	first.Scale(0.5,0.5)
	second.Turn(rand(-90, 90))

	spawned.color = rgb(rand(1, 255), rand(1, 255), rand(1, 255))

	animate(spawned, transform = first, time = 0.4 SECONDS, pixel_y = rand(-32, 32) + spawned.pixel_y, pixel_x = rand(-32, 32) + spawned.pixel_x, easing = LINEAR_EASING)
	animate(transform = second, time = 0.5 SECONDS, alpha = 0, pixel_y = spawned.pixel_y - 5, easing = LINEAR_EASING|EASE_OUT)
	addtimer(CALLBACK(src, PROC_REF(delete_particle), spawned), duration)

/obj/item/debug_confetti/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/particle_spewer/confetti)
