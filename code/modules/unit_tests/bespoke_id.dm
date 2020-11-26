/datum/unit_test/bespoke_id/Run()
	var/datum/element/base = /datum/element
	var/base_index = initial(base.id_arg_index)

	for(var/i in subtypesof(/datum/element))
		var/datum/element/faketype = i
		if((initial(faketype.element_flags) & ELEMENT_BESPOKE) && initial(faketype.id_arg_index) == base_index)
			Fail("A bespoke element was not configured with a proper id_arg_index: [faketype]")
