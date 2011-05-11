/mob/Logout()
	log_access("Logout: [key_name(src)]")
	if (admins[src.ckey])
		message_admins("Admin logout: [key_name(src)]")
	src.logged_in = 0

	..()

	return 1