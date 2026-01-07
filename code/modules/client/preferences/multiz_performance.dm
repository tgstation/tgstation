/// Boundary for how many z levels down to render properly before we start going cheapo mode
/datum/preference/numeric/multiz_performance
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "multiz_performance"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = MULTIZ_PERFORMANCE_DISABLE
	maximum = MAX_EXPECTED_Z_DEPTH - 1

/datum/preference/numeric/multiz_performance/create_default_value()
	return -1

/datum/preference/numeric/multiz_performance/apply_to_client(client/client, value)
	// Update the plane master group's layering
	var/datum/hud/my_hud = client.mob?.hud_used
	if(!my_hud)
		return

	for(var/group_key in my_hud.master_groups)
		var/datum/plane_master_group/group = my_hud.master_groups[group_key]
		group.build_planes_offset(my_hud, my_hud.current_plane_offset)
