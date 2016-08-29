/mob/dead/observer/Login()
	..()

	ghost_accs = client.prefs.ghost_accs
	ghost_others = client.prefs.ghost_others
	var/preferblue_form = null

	if(IsAdminGhost(src))
		has_unlimited_silicon_privilege = 1

	if(client.prefs.unlock_content)
		preferblue_form = client.prefs.ghost_form
		ghost_orbit = client.prefs.ghost_orbit

	update_icon(preferblue_form)
	updateghostimages()
