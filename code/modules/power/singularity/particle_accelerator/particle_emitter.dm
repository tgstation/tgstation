/obj/station_objects/particle_accelerator/particle_emitter
	name = "Particle Accelerator Emitter"
	desc = "Part of a Particle Accelerator, might not want to stand near this end."
	icon = 'particle_accelerator.dmi'
	icon_state = "none"
	var
		fire_delay = 50
		last_shot = 0

	center
		icon_state = "emitter_center"

	left
		icon_state = "emitter_left"

	right
		icon_state = "emitter_right"


	update_icon()
		return//Add overlays here


	proc
		set_delay(var/delay)
			if(delay && delay >= 0)
				src.fire_delay = delay
				return 1
			return 0


		emit_particle(var/strength = 0)
			if((src.last_shot + src.fire_delay) <= world.time)
				src.last_shot = world.time
				var/obj/effects/accelerated_particle/A = null
				var/turf/T = get_step(src,dir)
				switch(strength)
					if(0)
						A = new/obj/effects/accelerated_particle/weak(T, dir)
					if(1)
						A = new/obj/effects/accelerated_particle(T, dir)
					if(2)
						A = new/obj/effects/accelerated_particle/strong(T, dir)
				if(A)
					A.dir = src.dir
					return 1
			return 0