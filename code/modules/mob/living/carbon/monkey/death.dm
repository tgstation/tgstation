/mob/living/carbon/monkey/gib()
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

	flick("gibbed-m", animation)
	gibs(loc, viruses, dna)

	spawn(15)
		if(animation)	del(animation)
		if(src)			del(src)

/mob/living/carbon/monkey/dust()
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

	flick("dust-m", animation)
	new /obj/effect/decal/ash(loc)

	spawn(15)
		if(animation)	del(animation)
		if(src)			del(src)


/mob/living/carbon/monkey/death(gibbed)
	if(stat == DEAD)	return
	if(healths)			healths.icon_state = "health5"
	stat = DEAD

	if(!gibbed)
		for(var/mob/O in viewers(src, null))
			O.show_message("<b>The [name]</b> lets out a faint chimper as it collapses and stops moving...", 1) //ded -- Urist

	update_canmove()
	if(blind)	blind.layer = 0

	ticker.mode.check_win()

	return ..(gibbed)