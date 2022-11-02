/// Whether or not to toggle ambient occlusion, the shadows around people
/datum/preference/toggle/multiz_parallax
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "multiz_parallax"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/multiz_parallax/apply_to_client(client/client, value)
	// Update the plane master group's Z transforms.

	var/datum/hud/my_hud = client.mob?.hud_used
	if(!my_hud)
		return

	var/datum/plane_master_group/group = my_hud.get_plane_group(PLANE_GROUP_MAIN)
	group.transform_lower_turfs(my_hud, my_hud.current_plane_offset)
