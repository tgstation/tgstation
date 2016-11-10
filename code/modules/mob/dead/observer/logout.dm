/mob/dead/observer/Logout()
	if (client)
		client.images -= ghost_darkness_images
	if(observetarget)
		if(ismob(observetarget))
			var/mob/target = observetarget
			if(target.observers)
				target.observers -= src
				UNSETEMPTY(target.observers)
			observetarget = null
	..()
	spawn(0)
		if(src && !key)	//we've transferred to another mob. This ghost should be deleted.
			qdel(src)
