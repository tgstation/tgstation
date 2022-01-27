/mob/dead/observer/Logout()
	update_z(null)
	if (client)
		client.images -= (GLOB.ghost_images_default+GLOB.ghost_images_simple)

	if(observetarget && ismob(observetarget))
		cleanup_observe()
	..()
	// This is one of very few spawn()s left in our codebase
	// Yes it needs to be like this
	// No, you're not allowed to use spawn() yourself, unless you're making something that needs to work outside timers
	// Don't be a dumbass, I will always be watching
	spawn(0)
		if(src && !key) //we've transferred to another mob. This ghost should be deleted.
			qdel(src)
