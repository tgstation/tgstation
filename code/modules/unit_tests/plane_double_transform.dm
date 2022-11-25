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
	for(var/plane_key as anything in our_group.plane_masters)
		var/atom/movable/screen/plane_master/plane = our_group.plane_masters[plane_key]
		if(plane.render_target)
			render_target_to_plane[plane.render_target] = plane


	for(var/plane_key as anything in our_group.plane_masters)
		var/atom/movable/screen/plane_master/plane = our_group.plane_masters[plane_key]

		if(!plane.multiz_scaled)
			continue

		// Walk the relay targets
		for(var/target_plane in plane.render_relay_planes)
			var/atom/movable/screen/plane_master/target = our_group.plane_masters["[target_plane]"]
			if(target.multiz_scaled)
				TEST_FAIL("[plane.type] draws a render relay into [target.type]. Both are scaled by multiz, so this will cause strange transforms.\n\
				consider making a new render plate that they can both draw to instead, or something of that nature.")

		// Now we walk for filters that take from us
		for(var/filter_id in plane.filter_data)
			var/list/filter = plane.filter_data[filter_id]
			if(!filter["render_source"])
				continue
			var/atom/movable/screen/plane_master/target = render_target_to_plane[filter["render_source"]]
			if(target.multiz_scaled)
				TEST_FAIL("[plane.type] draws a render relay into [target.type]. Both are scaled by multiz, so this will cause strange transforms.\n\
				consider making a new render plate that they can both draw to instead, or something of that nature.")

