/mob/Logout()
	log_access("Logout: [key_name(src)]")
	src.logged_in = 0

	..()

	return 1