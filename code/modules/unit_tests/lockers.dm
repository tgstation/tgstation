/// Checks that the length of the initial contents of a locker doesn't exceed its storage capacity.
/// Also checks that nothing inside that isn't immediate is a steal objective.
/datum/unit_test/lockers

/datum/unit_test/lockers/Run()
	var/list/all_lockers = subtypesof(/obj/structure/locker)
	//Supply pods. They are sent, crashed, opened and never closed again. They also cause exceptions in nullspace.
	all_lockers -= typesof(/obj/structure/locker/supplypod)

	for(var/locker_type in all_lockers)
		var/obj/structure/locker/locker = allocate(locker_type)
		if(QDELETED(locker)) // this is here because the emlocker subtype has a chance of returning a qdel hint on initialize
			continue

		// Copy is necessary otherwise locker.contents - immediate_contents returns an empty list
		var/list/immediate_contents = locker.contents.Copy()
		locker.PopulateContents()
		var/contents_len = length(locker.contents)

		if(contents_len > locker.storage_capacity)
			TEST_FAIL("Initial Contents of [locker.type] ([contents_len]) exceed its storage capacity ([locker.storage_capacity]).")

		for (var/obj/item/item in locker.contents - immediate_contents)
			if (item.type in GLOB.steal_item_handler.objectives_by_path)
				TEST_FAIL("[locker_type] contains a steal objective [item.type] in PopulateContents(). Move it to populate_contents_immediate().")
