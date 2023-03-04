/datum/unit_test/bespoke_id/Run()
	var/datum/element/base = /datum/element
	var/base_index = initial(base.argument_hash_start_idx)

	for(var/i in subtypesof(/datum/element))
		var/datum/element/faketype = i
		if((initial(faketype.element_flags) & ELEMENT_BESPOKE) && initial(faketype.argument_hash_start_idx) == base_index)
			TEST_FAIL("A bespoke element was not configured with a proper argument_hash_start_idx: [faketype]")
