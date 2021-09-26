/mob/dead/observer/Logout()
	update_z(null)
	if (client)
		client.images -= (GLOB.ghost_images_default+GLOB.ghost_images_simple)

	if(observetarget)
		if(ismob(observetarget))
			var/mob/target = observetarget
			if(target.observers)
				target.observers -= src
				UNSETEMPTY(target.observers)
			observetarget = null
			client?.perspective = initial(client.perspective)
			sight = initial(sight)
	..()
	spawn(0)
		if(src && !key) //we've transferred to another mob. This ghost should be deleted.
			qdel(src)
