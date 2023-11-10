/datum/component/particle_spewer/snow
	icon_file = 'monkestation/code/modules/outdoors/icons/effects/particles/particle.dmi'
	particle_state = "cross"
	burst_amount = 4
	duration = 2 SECONDS

/datum/component/particle_spewer/snow/animate_particle(obj/effect/abstract/particle/spawned)
	var/chance = rand(1, 10)
	switch(chance)
		if(1 to 2)
			spawned.icon_state = "cross"
		if(3 to 4)
			spawned.icon_state = "snow_2"
		if(5 to 6)
			spawned.icon_state = "snow_3"
		else
			spawned.icon_state = "snow_1"

	spawned.pixel_x += rand(-3, 3)
	spawned.pixel_y += rand(-3, 3)

	animate(spawned, pixel_y = spawned.pixel_y - 32, time = 2 SECONDS)
	animate(spawned, alpha = 25, time = 1.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(delete_particle), spawned), duration)
