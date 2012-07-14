/mob/living/carbon/brain/death(gibbed)
	if(stat == DEAD)	return
	if(!gibbed && container && istype(container, /obj/item/device/mmi))//If not gibbed but in a container.
		for(var/mob/O in viewers(container, null))
			O.show_message(text("\red <B>[]'s MMI flatlines!</B>", src), 1, "\red You hear something flatline.", 2)
		container.icon_state = "mmi_dead"
	stat = DEAD

	if(blind)	blind.layer = 0
	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = 2

	tod = worldtime2text() //weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)	//mind. ?

	return ..(gibbed)