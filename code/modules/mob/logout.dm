/mob/Logout()
	log_message("[key_name(src)] is no longer owning mob [src]", INDIVIDUAL_OWNERSHIP_LOG)
	SStgui.on_logout(src)
	unset_machine()
	GLOB.player_list -= src

	..()

	if(loc)
		loc.on_log(FALSE)

	return TRUE
