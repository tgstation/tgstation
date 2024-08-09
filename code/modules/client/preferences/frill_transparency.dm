/datum/preference/toggle/frill_transparency
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "frill_transparent_pref"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/frill_transparency/apply_to_client(client/client, value)
	var/datum/hud/working_hud = client?.mob?.hud_used
	if(!working_hud)
		return
	for(var/atom/movable/screen/plane_master/frill/frill as anything in working_hud.get_true_plane_masters(RENDER_PLANE_FRILL))
		frill.show_to(client.mob)
