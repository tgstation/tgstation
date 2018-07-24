/////////////////////////////////////////////
//SPARK SYSTEM (like steam system)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like the RCD, so then you can just call start() and the sparks
// will always spawn at the items location.
/////////////////////////////////////////////

/proc/do_sparks(n, c, source)
	// n - number of sparks
	// c - cardinals, bool, do the sparks only move in cardinal directions?
	// source - source of the sparks.

	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(n, c, source)
	sparks.autocleanup = TRUE
	sparks.start()


/obj/effect/particle_effect/sparks
	name = "sparks"
	icon_state = "sparks"
	anchored = TRUE
	light_range = 1

/obj/effect/particle_effect/sparks/Initialize()
	. = ..()
	flick("sparks", src) // replay the animation
	playsound(src.loc, "sparks", 100, 1)
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(35,5)
	QDEL_IN(src, 20)

/obj/effect/particle_effect/sparks/Destroy()
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(35,1)
	return ..()

/obj/effect/particle_effect/sparks/Move()
	..()
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(35,1)

/datum/effect_system/spark_spread
	effect_type = /obj/effect/particle_effect/sparks


//electricity

/obj/effect/particle_effect/sparks/electricity
	name = "lightning"
	icon_state = "electricity"

/datum/effect_system/lightning_spread
	effect_type = /obj/effect/particle_effect/sparks/electricity
