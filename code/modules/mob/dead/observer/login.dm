/mob/dead/observer/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	ghost_accs = client.prefs.read_preference(/datum/preference/choiced/ghost_accessories)
	ghost_others = client.prefs.read_preference(/datum/preference/choiced/ghost_others)
	var/preferred_form = null

	if(isAdminGhostAI(src))
		has_unlimited_silicon_privilege = TRUE

	if(client.prefs.unlock_content)
		preferred_form = client.prefs.read_preference(/datum/preference/choiced/ghost_form)
		ghost_orbit = client.prefs.read_preference(/datum/preference/choiced/ghost_orbit)

	var/turf/T = get_turf(src)
	if (isturf(T))
		update_z(T.z)

	update_icon(ALL, preferred_form)
	updateghostimages()
	client.set_right_click_menu_mode(FALSE)
	lighting_cutoff = default_lighting_cutoff()
	update_sight()


