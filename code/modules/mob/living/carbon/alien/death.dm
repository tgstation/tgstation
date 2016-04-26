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
