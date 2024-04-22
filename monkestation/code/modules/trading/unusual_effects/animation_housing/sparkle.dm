/datum/component/particle_spewer/sparkle
	icon_file = 'goon/icons/effects/particles.dmi'
	particle_state = "sparkle"

	unusual_description = "shiny"
	duration = 0.7 SECONDS
	spawn_interval = 0.3 SECONDS
	burst_amount = 0
	offsets = FALSE

/datum/component/particle_spewer/sparkle/animate_particle(obj/effect/abstract/particle/spawned)
	var/matrix/first = matrix()
	spawned.pixel_x += rand(-12, 12) // can be anywhere in the tile bounds
	spawned.pixel_y += rand(-12, 12)
	first.Turn(rand(-90, 90))
	first.Scale(0.1, 0.1)
	spawned.transform = first

	first.Scale(10)
	animate(spawned, transform = first, time = 0.3 SECONDS, alpha = 220)

	first.Scale(0.1 * 0.1)
	first.Turn(rand(-90, 90))
	animate(transform = first, time = 0.3 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(delete_particle), spawned), duration)
