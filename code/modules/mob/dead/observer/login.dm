/mob/dead/observer/Login()
	..()

	if(check_rights(R_ADMIN, 0))
		has_unlimited_silicon_privilege = 1

	if(client.prefs.unlock_content)
		update_icon(client.prefs.ghost_form)
		ghost_orbit = client.prefs.ghost_orbit

	updateghostimages()
