/datum/component/particle_spewer/movement/weh
	unusual_description = "weh"
	duration = 5 SECONDS
	burst_amount = 3

	particle_state = "map_plushie_lizard"
	icon_file = 'icons/obj/toys/plushes.dmi'

/datum/component/particle_spewer/movement/weh/animate_particle(obj/effect/abstract/particle/spawned)
	var/matrix/first = matrix()
	var/matrix/second = matrix()

	spawned.pixel_x += rand(-3,3)
	spawned.pixel_y += rand(-3,3)

	first.Turn(rand(-90, 90))
	first.Scale(0.5,0.5)
	second.Turn(rand(-90, 90))

	spawned.color = rgb(rand(1, 255), rand(1, 255), rand(1, 255))

	animate(spawned, transform = first, time = 0.4 SECONDS, pixel_y = rand(-1, 12) + spawned.pixel_y, pixel_x = rand(-32, 32) + spawned.pixel_x, easing = JUMP_EASING)
	animate(transform = second, time = 0.5 SECONDS, pixel_y = spawned.pixel_y - 32)
	animate(spawned, alpha = 0, time = duration)
	addtimer(CALLBACK(src, PROC_REF(delete_particle), spawned), duration)
