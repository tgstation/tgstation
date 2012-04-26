/mob/living/silicon/gib()
	death(1)
	var/atom/movable/overlay/animation = null
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src

//	flick("gibbed-r", animation)
	robogibs(loc, viruses)

	spawn(15)
		if(animation)	del(animation)
		if(src)			del(src)

/mob/living/silicon/dust()
	death(1)
	var/atom/movable/overlay/animation = null
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src

//	flick("dust-r", animation)
	new /obj/effect/decal/remains/robot(loc)

	spawn(15)
		if(animation)	del(animation)
		if(src)			del(src)
