<<<<<<< HEAD
/mob/living/carbon/alien/spawn_gibs()
	xgibs(loc, viruses)

/mob/living/carbon/alien/gib_animation()
	PoolOrNew(/obj/effect/overlay/temp/gib_animation, list(loc, "gibbed-a"))

/mob/living/carbon/alien/spawn_dust()
	new /obj/effect/decal/remains/xeno(loc)

/mob/living/carbon/alien/dust_animation()
	PoolOrNew(/obj/effect/overlay/temp/dust_animation, list(loc, "dust-a"))
=======
/mob/living/carbon/alien/gib()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "gibbed-a", sleeptime = 15)
	xgibs(loc, viruses)
	dead_mob_list -= src

	qdel(src)

/mob/living/carbon/alien/dust()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	dropBorers(1)

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-a", sleeptime = 15)
	new /obj/effect/decal/remains/xeno(loc)
	dead_mob_list -= src

	qdel(src)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
