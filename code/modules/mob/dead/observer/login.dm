/mob/dead/observer/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	ghost_accs = client.prefs.ghost_accs
	ghost_others = client.prefs.ghost_others
	var/preferred_form = null

	if(isAdminGhostAI(src))
		has_unlimited_silicon_privilege = 1

	if(client.prefs.unlock_content)
		preferred_form = client.prefs.ghost_form
		ghost_orbit = client.prefs.ghost_orbit

	var/turf/T = get_turf(src)
	if (isturf(T))
		update_z(T.z)

	update_icon(preferred_form)
	updateghostimages()
