/// Preference for having particles enabled or disabled
/datum/preference/toggle/particles
	savefile_key = "particles"
	savefile_identifier = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES

/datum/preference/toggle/particles/apply_to_client(client/client, value)
	// gib or take the particle layer

	var/datum/hud/my_hud = client.mob?.hud_used
	if(!my_hud)
		return

	for(var/atom/movable/screen/plane_master/particle_plane in my_hud.get_true_plane_masters(PARTICLE_PLANE))
		if(value)
			particle_plane.unhide_plane(client.mob)
		else
			particle_plane.hide_plane(client.mob)
