/mob/Logout()
	SEND_SIGNAL(src, COMSIG_MOB_LOGOUT)
	log_message("[key_name(src)] is no longer owning mob [src]([src.type])", LOG_OWNERSHIP)
	SStgui.on_logout(src)
	remove_from_player_list()
	update_ambience_area(null) // Unset ambience vars so it plays again on login
	// Clears away the frill mask
	// Wallening todo: make this better. Also why are these not cached exactly?
	if(client)
		client.images.Remove(frill_mask)
	LAZYREMOVE(update_on_z, frill_mask)
	frill_mask = null

	..()

	if(loc)
		loc.on_log(FALSE)

	become_uncliented()

	return TRUE
