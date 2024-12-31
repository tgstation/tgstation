/// Ensures we have no invalid plane/layer combos post init
/datum/unit_test/plane_layer_sanity
	priority = TEST_LONGER

/datum/unit_test/plane_layer_sanity/Run()
	// This fucker's gonna be slow, I'm sorry
	for(var/mutable_appearance/appearance)
		check_topdown_validity(appearance)
	for(var/atom/thing)
		check_topdown_validity(thing)
