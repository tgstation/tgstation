/// Whether or not to toggle ambient occlusion, the shadows around people
/datum/preference/toggle/ambient_occlusion
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "ambientocclusion"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/ambient_occlusion/apply_to_client(client/client, value)
	/// Backdrop for the game world plane.
	for(var/atom/movable/screen/plane_master/plane_master as anything in client.mob?.hud_used?.get_true_plane_masters(RENDER_PLANE_GAME_WORLD))
		plane_master.show_to(client.mob)
	for(var/atom/movable/screen/plane_master/plane_master as anything in client.mob?.hud_used?.get_true_plane_masters(RUNECHAT_PLANE))
		plane_master.show_to(client.mob)
