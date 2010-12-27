/mob/living/silicon/aihologram/Del() //can't "die" per se, so it's only Del()
	if(parent_ai)
		parent_ai:client = src.client //parent_ai is always an ai mob, so : is okay
	..()