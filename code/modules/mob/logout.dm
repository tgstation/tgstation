/mob/Logout()
	SEND_SIGNAL(src, COMSIG_MOB_LOGOUT)
	log_message("[key_name(src)] is no longer owning mob [src]([src.type])", LOG_OWNERSHIP)
	SStgui.on_logout(src)
	unset_machine()
	remove_from_player_list()
	for(var/datum/atom_hud/alternate_appearance/alt_hud as anything in GLOB.active_alternate_appearances)
		alt_hud.hide_from(src)
	..()

	if(loc)
		loc.on_log(FALSE)

	become_uncliented()

	return TRUE
