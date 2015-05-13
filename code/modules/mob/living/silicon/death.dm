/mob/living/silicon/spawn_gibs()
	robogibs(loc, viruses)

/mob/living/silicon/gib(var/animation = 0) // Please don't remove this thinking this proc does nothing, it is changing the default value for animation.
	..()

/mob/living/silicon/spawn_dust()
	new /obj/effect/decal/remains/robot(loc)
