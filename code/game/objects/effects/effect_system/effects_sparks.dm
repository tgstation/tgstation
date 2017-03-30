/////////////////////////////////////////////
//SPARK SYSTEM (like steam system)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like the RCD, so then you can just call start() and the sparks
// will always spawn at the items location.
/////////////////////////////////////////////

/obj/effect/particle_effect/sparks
	name = "sparks"
	icon_state = "sparks"
	anchored = 1
	light_range = 1

/obj/effect/particle_effect/sparks/New()
	..()
	flick("sparks", src) // replay the animation
	playsound(src.loc, "sparks", 100, 1)
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(1000,100)
	QDEL_IN(src, 20)

/obj/effect/particle_effect/sparks/Destroy()
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(1000,100)
	return ..()

/obj/effect/particle_effect/sparks/Move()
	..()
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(1000,100)

/datum/effect_system/spark_spread
	effect_type = /obj/effect/particle_effect/sparks


//electricity

/obj/effect/particle_effect/sparks/electricity
	name = "lightning"
	icon_state = "electricity"

/datum/effect_system/lightning_spread
	effect_type = /obj/effect/particle_effect/sparks/electricity
