/mob/living/Logout()
	..()
	if(!key && mind)	//key and mind have become seperated.
		mind.active = 0	//This is to stop say, a mind.transfer_to call on a corpse causing a ghost to re-enter its body.
