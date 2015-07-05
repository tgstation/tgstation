/mob/living/silicon/gib()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

//	anim(target = src, a_icon = 'icons/mob/mob.dmi', /*flick_anim = "gibbed-r"*/, sleeptime = 15)
	robogibs(loc, viruses)

	dead_mob_list -= src
	qdel(src)

/mob/living/silicon/dust()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

//	anim(target = src, a_icon = 'icons/mob/mob.dmi', /*flick_anim = "dust-r"*/, sleeptime = 15)
	new /obj/effect/decal/remains/robot(loc)

	dead_mob_list -= src
	qdel(src)
