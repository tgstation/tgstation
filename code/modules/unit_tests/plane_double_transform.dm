/// Ensures plane masters that get shrunk by multiz NEVER render into each other
/datum/unit_test/plane_double_transform

/datum/unit_test/plane_double_transform/Run()
	// We're going to operate off the actual plane master setup of an actual mob
	// It's not perfect, but it'll help things a lot
	var/mob/living/carbon/human/judger = allocate(/mob/living/carbon/human/consistent)
	// Hack to account for not having an actual hud
	var/datum/plane_master_group/hudless/our_group = allocate(/datum/plane_master_group/hudless)
	our_group.our_mob = judger
	our_group.show_hud()
	// End hack

	// Generates a list of render target -> PM for future use
	var/list/render_target_to_plane = list()
	// List of all the plane masters that are being scaled by multiz. These cannot feed into each other
	var/list/atom/movable/screen/plane_master/input_planes = list()
	for(var/plane_key in our_group.plane_masters)
		var/atom/movable/screen/plane_master/plane = our_group.plane_masters[plane_key]
		if(plane.render_target)
			render_target_to_plane[plane.render_target] = plane
		if(plane.multiz_scaled)
			input_planes += plane_key

	// We need to walk all our input planes and see if they feed into any plane masters that are also multiz scaled
	for(var/input_key as anything in input_planes)
		var/list/keys_to_walk = list()
		var/atom/movable/screen/plane_master/input_plane = our_group.plane_masters[input_key]
		keys_to_walk[input_key] = "[input_plane.type]"
		var/key_index = 0
		while(key_index < length(keys_to_walk))
			key_index += 1
			var/next_plane_key = keys_to_walk[key_index]
			var/atom/movable/screen/plane_master/next_plane = our_group.plane_masters[next_plane_key]

			for(var/target_plane in next_plane.render_relay_planes)
				var/target_key = "[target_plane]"
				var/atom/movable/screen/plane_master/target = our_group.plane_masters["[target_key]"]
				if(!keys_to_walk[target_key])
					keys_to_walk[target_key] = "[keys_to_walk[next_plane_key]]-[target.type]"
				if(target.multiz_scaled)
					TEST_FAIL("[input_plane.type] is eventually drawn (via render relays) onto [target.type] {[keys_to_walk[target_key]]}. Both are scaled by multiz, so this will cause strange transforms.\n\
					consider making a new render plate that they can both draw to instead, or something of that nature.")

			// Now we walk for filters that take from us
			for(var/list/filter in next_plane.filter_data)
				if(!filter["render_source"])
					continue
				var/atom/movable/screen/plane_master/target = render_target_to_plane[filter["render_source"]]
				var/target_key = "[target.plane]"
				if(!keys_to_walk[target_key])
					keys_to_walk[target_key] = "[keys_to_walk[next_plane_key]]-[target.type]"
				if(target.multiz_scaled)
					TEST_FAIL("[input_plane.type] is eventually drawn (via render relays) onto [target.type] {[keys_to_walk[target_key]]}. Both are scaled by multiz, so this will cause strange transforms.\n\
					consider making a new render plate that they can both draw to instead, or something of that nature.")
