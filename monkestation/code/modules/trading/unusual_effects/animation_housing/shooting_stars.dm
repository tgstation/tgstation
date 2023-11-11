/datum/component/particle_spewer/shooting_star
	icon_file = 'goon/icons/effects/particles.dmi'
	particle_state = "starsmall"

	unusual_description = "shooting star"
	duration = 5 SECONDS
	burst_amount = 5
	offsets = FALSE
	//has a chance to randomly change on animate
	var/direction = NORTH

/datum/component/particle_spewer/shooting_star/animate_particle(obj/effect/abstract/particle/spawned)
	if(prob(10))
		direction = pick(NORTH, SOUTH, EAST, WEST)
	
	spawned.dir = direction
	if(prob(30))
		spawned.icon_state = "starlarge"
	if(direction & NORTH|SOUTH)
		spawned.pixel_x += rand(-80, 80)

	if(direction & EAST|WEST)
		spawned.pixel_y += rand(-80, 80)

	switch(direction)
		if(NORTH)
			animate(spawned, time = rand(0.5 SECONDS, duration), pixel_y = spawned.pixel_y + 160, alpha = 25)
		if(SOUTH)
			animate(spawned, time = rand(0.5 SECONDS, duration), pixel_y = spawned.pixel_y - 160, alpha = 25)
		if(EAST)
			animate(spawned, time = rand(0.5 SECONDS, duration), pixel_x = spawned.pixel_x + 160, alpha = 25)
		if(WEST)
			animate(spawned, time = rand(0.5 SECONDS, duration), pixel_x = spawned.pixel_x - 160, alpha = 25)
	addtimer(CALLBACK(src, PROC_REF(delete_particle), spawned), duration)
	