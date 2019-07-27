<<<<<<< HEAD
/mob/living/Logout()
	update_z(null)
	..()
	if(!key && mind)	//key and mind have become separated.
=======
/mob/living/Logout()
	update_z(null)
	..()
	if(!key && mind)	//key and mind have become separated.
>>>>>>> Updated this old code to fork
		mind.active = 0	//This is to stop say, a mind.transfer_to call on a corpse causing a ghost to re-enter its body.