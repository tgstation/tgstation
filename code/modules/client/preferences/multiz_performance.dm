/// We expect at most 3 layers of multiz
/// Increment this define if you make a huge map. this has a layer of wiggle room since I don't trust you all
/// If you modify this, you'll need to modify the tsx file too
#define MAX_EXPECTED_Z_DEPTH 3
/// Boundary for how many z levels down to render properly before we start going cheapo mode
/datum/preference/numeric/multiz_performance
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "multiz_performance"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = -1
	maximum = MAX_EXPECTED_Z_DEPTH

/datum/preference/numeric/multiz_performance/create_default_value()
	return -1

/datum/preference/numeric/multiz_performance/apply_to_client(client/client, value)
	// Update the plane master group's layering
	var/datum/hud/my_hud = client.mob?.hud_used
	if(!my_hud)
		return

	for(var/group_key as anything in my_hud.master_groups)
		var/datum/plane_master_group/group = my_hud.master_groups[group_key]
		group.transform_lower_turfs(my_hud, my_hud.current_plane_offset)
