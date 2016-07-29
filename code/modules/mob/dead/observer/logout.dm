<<<<<<< HEAD
/mob/dead/observer/Logout()
	if (client)
		client.images -= ghost_darkness_images
	..()
	spawn(0)
		if(src && !key)	//we've transferred to another mob. This ghost should be deleted.
			qdel(src)
=======
/mob/dead/observer/Logout()
	..()
	spawn(0)
		if(src && !key)	//we've transferred to another mob. This ghost should be deleted.
			qdel(src)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
