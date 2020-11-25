/datum/unit_test/merge_type/Run()
	var/list/paths = subtypesof(/obj/item/stack) - /obj/item/stack/sheet - /obj/item/stack/sheet/mineral

	for(var/stackpath in paths)
		if(!initial(stackpath.merge_type))
			Fail("([stackpath.type]) lacks set merge_type!")
