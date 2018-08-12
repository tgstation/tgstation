/mob/Logout()
	log_message("[key_name(src)] is no longer owning mob [src]", LOG_OWNERSHIP)
	SStgui.on_logout(src)
	unset_machine()
	GLOB.player_list -= src

	..()

	if(loc)
		loc.on_log(FALSE)

	return TRUE
