/mob/living/carbon/brain/say(var/message)
	if (silent)
		return

	if(!(container && istype(container, /obj/item/device/mmi)))
		return //No MMI, can't speak, bucko./N
	else	..()