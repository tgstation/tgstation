/mob/living/carbon/brain/say(var/message)
	if(!container && stat != 2) return //In case of some mysterious happenings where a "living" brain is not in an MMI, don't let it speak. --NEO
	..()