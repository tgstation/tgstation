<<<<<<< HEAD
/mob/living/carbon/brain/death(gibbed)
	if(stat == DEAD)
		return
	stat = DEAD

	if(!gibbed && container)//If not gibbed but in a container.
		var/obj/item/device/mmi = container
		mmi.visible_message("<span class='warning'>[src]'s MMI flatlines!</span>", \
					"<span class='italics'>You hear something flatline.</span>")
		mmi.update_icon()

	return ..()

/mob/living/carbon/brain/gib()
	if(container)
		qdel(container)//Gets rid of the MMI if there is one
	if(loc)
		if(istype(loc,/obj/item/organ/brain))
			qdel(loc)//Gets rid of the brain item
	..()
=======
/mob/living/carbon/brain/death(gibbed)
	if(stat == DEAD)	return
	if(!gibbed && container && istype(container, /obj/item/device/mmi))//If not gibbed but in a container.
		container.OnMobDeath(src)

	stat = DEAD

	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO

	tod = worldtime2text() //weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)	//mind. ?

	return ..(gibbed)

/mob/living/carbon/brain/gib()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	if(container && istype(container, /obj/item/device/mmi))
		qdel(container)//Gets rid of the MMI if there is one
	if(loc)
		if(istype(loc,/obj/item/organ/brain))
			qdel(loc)//Gets rid of the brain item

	anim(target = src, a_icon = 'icons/mob/mob.dmi', /*flick_anim = "gibbed-m"*/, sleeptime = 15)
	gibs(loc, viruses, dna)

	dead_mob_list -= src
	qdel(src)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
