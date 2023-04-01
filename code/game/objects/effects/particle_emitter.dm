///Particle holder for turfs (who cant hold their own emit particles ;_;). Add to a turf with turf..make_stick_to_turf(me)
/obj/effect/abstract/particle_holder
	particles = null //this is the thing you set to the particles
	anchored = TRUE

/obj/effect/abstract/particle_holder/lava/Initialize(mapload)
	. = ..()

	particles = new /particles/lava

/obj/effect/abstract/particle_holder/plasma/Initialize(mapload)
	. = ..()

	particles = new /particles/lava/plasma
