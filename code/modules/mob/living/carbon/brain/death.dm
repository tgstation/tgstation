/mob/living/carbon/brain/death(gibbed)
	if(stat == DEAD)	return
	if(!gibbed && container && istype(container, /obj/item/device/mmi))//If not gibbed but in a container.
		container.visible_message("<span class='warning'>[src]'s MMI flatlines!</span>", \
					"<span class='italics'>You hear something flatline.</span>")
		if(istype(src,/obj/item/organ/brain/alien))
			container.icon_state = "mmi_alien_dead"
		else
			container.icon_state = "mmi_dead"
	stat = DEAD

	if(blind)	blind.layer = 0
	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO

	tod = worldtime2text() //weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)	//mind. ?

	return ..(gibbed)

/mob/living/carbon/brain/gib(animation = 0)
	if(container && istype(container, /obj/item/device/mmi))
		qdel(container)//Gets rid of the MMI if there is one
	if(loc)
		if(istype(loc,/obj/item/organ/brain))
			qdel(loc)//Gets rid of the brain item
	..()