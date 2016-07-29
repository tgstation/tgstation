<<<<<<< HEAD
/mob/living/carbon/monkey/gib_animation()
	PoolOrNew(/obj/effect/overlay/temp/gib_animation, list(loc, "gibbed-m"))

/mob/living/carbon/monkey/dust_animation()
	PoolOrNew(/obj/effect/overlay/temp/dust_animation, list(loc, "dust-m"))

/mob/living/carbon/monkey/death(gibbed)
	if(stat == DEAD)
		return

	stat = DEAD

	if(!gibbed)
		emote("deathgasp")

	if(ticker && ticker.mode)
		ticker.mode.check_win()

=======
/mob/living/carbon/monkey/gib()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "gibbed-m", sleeptime = 15)
	gibs(loc, viruses, dna)

	qdel(src)

/mob/living/carbon/monkey/dust()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	dropBorers(1)

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-m", sleeptime = 15)
	new /obj/effect/decal/cleanable/ash(loc)

	qdel(src)


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

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	return ..(gibbed)