
/obj/machinery/rust/rad_source
	var/mega_energy = 0
	var/time_alive = 0
	var/source_alive = 2
	New()
		..()

	process()
		..()
		//fade away over time
		if(source_alive > 0)
			time_alive++
			source_alive--
		else
			time_alive -= 0.1
			if(time_alive < 0)
				del(src)

		//radiate mobs nearby here
		//

/*
/obj/machinery/rust
	proc/RadiateParticle(var/energy, var/ionizing, var/dir = 0)
		if(!dir)
			RadiateParticleRand(energy, ionizing)
		var/obj/effect/accelerated_particle/particle = new
		particle.dir = dir
		particle.ionizing = ionizing
		if(energy)
			particle.energy = energy
			//particle.invisibility = 2
		//
		return particle

	proc/RadiateParticleRand(var/energy, var/ionizing)
		var/turf/target
		var/particle_range = 3 * round(energy) + rand(3,20)
		if(energy > 1)
			//for penetrating radiation
			for(var/mob/M in range(particle_range))
				var/dist_ratio = particle_range / get_dist(M, src)
				//particles are more likely to hit a person if the person is closer
				// 1/8 = 12.5% (closest)
				// 1/360 = 0.27% (furthest)
				// variation of 12.2%
				if( rand() < (0.25 + dist_ratio * 12.5) )
					target = get_turf(M)
					break
			if(!target)
				target = pick(range(particle_range))
		else
			//for slower, non-penetrating radiation
			for(var/mob/M in view(particle_range))
				var/dist_ratio = particle_range / get_dist(M, src)
				if( rand() < (0.25 + dist_ratio * 12.5) )
					target = get_turf(M)
					break
			if(!target)
				target = pick(view(particle_range))
		var/obj/effect/accelerated_particle/particle = new
		particle.target = target
		particle.ionizing = ionizing
		if(energy)
			particle.energy = energy
			//particle.invisibility = 2
		//
		return particle
*/