/mob/dead/observer/Logout()
	update_z(null)
	if (client)
		client.images -= (GLOB.ghost_images_default+GLOB.ghost_images_simple)

	if(observetarget && ismob(observetarget))
		cleanup_observe()
	..()
	spawn(0)
		if(src && !key) //we've transferred to another mob. This ghost should be deleted.
			qdel(src)
