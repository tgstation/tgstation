/obj/structure/particle_accelerator/particle_emitter
	name = "EM Containment Grid"
	desc = "This launchs the Alpha particles, might not want to stand near this end."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "none"
	var/fire_delay = 50
	var/last_shot = 0

/obj/structure/particle_accelerator/particle_emitter/center
	icon_state = "emitter_center"
	reference = "emitter_center"

/obj/structure/particle_accelerator/particle_emitter/left
	icon_state = "emitter_left"
	reference = "emitter_left"

/obj/structure/particle_accelerator/particle_emitter/right
	icon_state = "emitter_right"
	reference = "emitter_right"

/obj/structure/particle_accelerator/particle_emitter/proc/set_delay(delay)
	if(delay >= 0)
		fire_delay = delay
		return 1
	return 0

/obj/structure/particle_accelerator/particle_emitter/proc/emit_particle(strength = 0)
	if((last_shot + fire_delay) <= world.time)
		last_shot = world.time
		var/turf/T = get_step(src,dir)
		switch(strength)
			if(0)
				new/obj/effect/accelerated_particle/weak(T, dir)
			if(1)
				new/obj/effect/accelerated_particle(T, dir)
			if(2)
				new/obj/effect/accelerated_particle/strong(T, dir)
			if(3)
				new/obj/effect/accelerated_particle/powerful(T, dir)
		return 1
	return 0
