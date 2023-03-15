/obj/emitter/rain
	alpha = 255
	particles = new/particles/rain
	var/static/list/particles/z_particles

/obj/emitter/rain/dense
	particles = new/particles/rain/dense

/obj/emitter/rain/sideways
	particles = new/particles/rain/sideways

/obj/emitter/rain/sideways/tile
	name = "Rain"
	particles = null

/obj/emitter/rain/sideways/tile/New()
	.=..()
	LAZYINITLIST(z_particles)
	var/z_level_str
	if(!src.z)
		z_level_str = "\"[2]\""
	else
		z_level_str = "\"[src.z]\""

	if(!z_particles[z_level_str])
		z_particles[z_level_str] = new/particles/rain/sideways/tile
	particles = z_particles[z_level_str]
