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
	var/matrix/second = matrix()
	var/matrix/default = matrix()

	if(prob(30))
		spawned.icon_state = "eighth"
	if(prob(25))
		spawned.icon_state = "quarter"

	spawned.pixel_x += rand(-24, 24)
	spawned.pixel_y += rand(-6, 6)
	first.Turn(rand(-90, 90))
	spawned.transform = first

	second = first
	second.Scale(4,4)
	second.Turn(rand(-90, 90))

	animate(spawned, transform = second, time = 1, alpha = 220)
	animate(transform = default, time = duration + rand(-5, 5), pixel_y = spawned.pixel_y + 32, alpha = 1)

	addtimer(CALLBACK(src, PROC_REF(delete_particle), spawned), duration + 0.6 SECONDS)
