/// Whether or not to toggle ambient occlusion, the shadows around people
/datum/preference/toggle/ambient_occlusion
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "ambientocclusion"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/ambient_occlusion/apply_to_client(client/client, value)
	var/datum/hud/our_hud = client.mob?.hud_used
	if(!our_hud)
		return
	if(!value)
		for(var/atom/movable/screen/plane_master/plane_master as anything in our_hud.get_true_plane_masters(RENDER_PLANE_GAME_WORLD_AO))
			plane_master.hide_plane(client.mob)
		for(var/atom/movable/screen/plane_master/plane_master as anything in our_hud.get_true_plane_masters(RENDER_PLANE_RUNECHAT_AO))
			plane_master.hide_plane(client.mob)
		return

	for(var/atom/movable/screen/plane_master/plane_master as anything in our_hud.get_true_plane_masters(RENDER_PLANE_GAME_WORLD_AO))
		plane_master.unhide_plane(client.mob)
	for(var/atom/movable/screen/plane_master/plane_master as anything in our_hud.get_true_plane_masters(RENDER_PLANE_RUNECHAT_AO))
		plane_master.unhide_plane(client.mob)
