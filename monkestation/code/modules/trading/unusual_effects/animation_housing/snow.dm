/datum/component/particle_spewer/snow
	unusual_description = "snowstorm"
	icon_file = 'monkestation/code/modules/outdoors/icons/effects/particles/particle.dmi'
	particle_state = "cross"
	burst_amount = 8
	duration = 2 SECONDS
	random_bursts = TRUE
	spawn_interval = 0.3 SECONDS

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

	if(prob(35))
		spawned.layer = ABOVE_MOB_LAYER
	spawned.pixel_x += rand(-12, 12)
	spawned.pixel_y += rand(-5, 5)

	animate(spawned, pixel_y = spawned.pixel_y - 32, time = 2 SECONDS)
	animate(spawned, alpha = 25, time = 1.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(delete_particle), spawned), duration)
