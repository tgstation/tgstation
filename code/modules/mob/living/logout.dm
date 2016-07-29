<<<<<<< HEAD
/mob/living/Logout()
	..()
	if(!key && mind)	//key and mind have become seperated.
		mind.active = 0	//This is to stop say, a mind.transfer_to call on a corpse causing a ghost to re-enter its body.
=======
/mob/living/Logout()
	..()
	if (mind)
		if(!key)	//key and mind have become seperated.
			mind.active = 0	//This is to stop say, a mind.transfer_to call on a corpse causing a ghost to re-enter its body.
	/* /vg/ EDIT
		if(!immune_to_ssd && sleeping < 2 && mind.active)
			sleeping = 2	//This causes instant sleep, but does not prolong it. See life.dm for furthering SSD.
	*/
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
