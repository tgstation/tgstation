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
	if(src.stat == DEAD)
		return

	if (src.healths)
		src.healths.icon_state = "health5"
	if(!gibbed)
		for(var/mob/O in viewers(src, null))
			O.show_message("<b>The [src.name]</b> lets out a faint chimper as it collapses and stops moving...", 1) //ded -- Urist

	src.stat = 2
	src.canmove = 0
	if (src.blind)
		src.blind.layer = 0
	src.lying = 1

	var/h = src.hand
	src.hand = 0
	drop_item()
	src.hand = 1
	drop_item()
	src.hand = h

	ticker.mode.check_win()

	if (src.key)
		spawn(50)
			if(src.key && src.stat == 2)
				src.client.verbs += /client/proc/ghost

	return ..(gibbed)