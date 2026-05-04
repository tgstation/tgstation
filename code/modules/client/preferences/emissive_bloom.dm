/// Size of the bloom filter applied to the emissive plane, mostly as a visual preference
/datum/preference/numeric/emissive_bloom
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "emissive_bloom"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = MAXIMUM_EMISSIVE_BLOOM_SIZE

/datum/preference/numeric/emissive_bloom/create_default_value()
	return DEFAULT_EMISSIVE_BLOOM_SIZE

/datum/preference/numeric/emissive_bloom/apply_to_client(client/client, value)
	// Update the plane master filter
	var/datum/hud/my_hud = client.mob?.hud_used
	if(!my_hud)
		return

	for(var/atom/movable/screen/plane_master/bloom as anything in my_hud.get_true_plane_masters(RENDER_PLANE_EMISSIVE_BLOOM))
		if (!bloom.get_filter("emissive_bloom"))
			if (value)
				bloom.add_filter("emissive_bloom", 2, bloom_filter(threshold = COLOR_BLACK, size = value, offset = ceil(value / 2)))
			continue

		if (value)
			bloom.modify_filter("emissive_bloom", list("size" = value, "offset" = ceil(value / 2)))
		else
			bloom.remove_filter("emissive_bloom")
