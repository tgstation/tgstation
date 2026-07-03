/mob
	var/logout_time = 0

/mob/Logout()
	logout_time = world.time
	. = ..()
