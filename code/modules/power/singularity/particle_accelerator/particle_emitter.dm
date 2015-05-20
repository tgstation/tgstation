//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/structure/particle_accelerator/particle_emitter
	name = "EM Containment Grid"
	desc_holder = "This launchs the Alpha particles, might not want to stand near this end."
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

/obj/structure/particle_accelerator/particle_emitter/update_icon()
	..()
	return

/obj/structure/particle_accelerator/particle_emitter/proc/set_delay(var/delay)
	if(delay && delay >= 0)
		src.fire_delay = delay
		return 1
	return 0


/obj/structure/particle_accelerator/particle_emitter/proc/emit_particle(var/strength = 0)
	if((src.last_shot + src.fire_delay) <= world.time)
		src.last_shot = world.time
		var/obj/effect/accelerated_particle/A = null
		var/turf/T = get_step(src,dir)
		switch(strength)
			if(0)
				A = new/obj/effect/accelerated_particle/weak(T, dir)
			if(1)
				A = new/obj/effect/accelerated_particle(T, dir)
			if(2)
				A = new/obj/effect/accelerated_particle/strong(T, dir)
			if(3)
				A = new/obj/effect/accelerated_particle/powerful(T, dir)
		if(A)
			A.dir = src.dir
			return 1
	return 0
