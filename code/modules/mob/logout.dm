/mob/Logout()
	SEND_SIGNAL(src, COMSIG_MOB_LOGOUT)
	log_message("[key_name(src)] is no longer owning mob [src]([src.type])", LOG_OWNERSHIP)
	SStgui.on_logout(src)
	unset_machine()
	remove_from_player_list()

	// Clears away the frill mask
	// Wallening todo: make this better. Also why are these not cached exactly?
	if(client)
		client.images.Remove(frill_oval_mask)
	frill_oval_mask = null

	..()

	if(loc)
		loc.on_log(FALSE)

	become_uncliented()

	return TRUE
