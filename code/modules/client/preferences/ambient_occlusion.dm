/// Whether or not to toggle ambient occlusion, the shadows around people
/datum/preference/toggle/ambient_occlusion
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "ambientocclusion"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/ambient_occlusion/apply_to_client(client/client, value)
	/// Backdrop for all game world planes.
	for(var/atom/movable/screen/plane_master/game_world/game_world_plane_master in client?.screen)
		game_world_plane_master.backdrop(client.mob)
