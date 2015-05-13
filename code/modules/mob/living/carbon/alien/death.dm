/mob/living/carbon/alien/spawn_gibs()
	xgibs(loc, viruses)

/mob/living/carbon/alien/gib_animation(var/animate)
	..(animate, "gibbed-a")

/mob/living/carbon/alien/spawn_dust()
	new /obj/effect/decal/remains/xeno(loc)

/mob/living/carbon/alien/spawn_dust()
	new /obj/effect/decal/remains/xeno(loc)

/mob/living/carbon/alien/dust_animation(var/animate)
	..(animate, "dust-a")

/mob/living/carbon/alien/dust(var/animation = 1)
	..()