/mob/living/carbon/alien/spawn_gibs(with_bodyparts)
	if(with_bodyparts)
		new /obj/effect/gibspawner/xeno(get_turf(src))
	else
		new /obj/effect/gibspawner/xenobodypartless(get_turf(src))

/mob/living/carbon/alien/gib_animation()
	new /obj/effect/temp_visual/gib_animation(loc, "gibbed-a")

/mob/living/carbon/alien/spawn_dust()
	new /obj/effect/decal/remains/xeno(loc)

/mob/living/carbon/alien/dust_animation()
	new /obj/effect/temp_visual/dust_animation(loc, "dust-a")
