/datum/unit_test/merge_type/Run()
	var/list/paths = subtypesof(/obj/item/stack) - /obj/item/stack/sheet - /obj/item/stack/sheet/mineral

	for(var/stackpath in paths)
		var/obj/item/stack = stackpath
		if(!initial(stack.merge_type))
			Fail("([stack]) lacks set merge_type variable!")
