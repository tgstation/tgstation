/// Checks that the length of the initial contents of a closet doesn't exceed its storage capacity.
/// Also checks that nothing inside that isn't immediate is a steal objective.
/datum/unit_test/closets

/datum/unit_test/closets/Run()
	var/list/all_closets = subtypesof(/obj/structure/closet)
	//Supply pods. They are sent, crashed, opened and never closed again. They also cause exceptions in nullspace.
	all_closets -= typesof(/obj/structure/closet/supplypod)
	/// these bitches spawn specially crafted humans with gear and moving organs being shuffled around through the whole process
	all_closets -= typesof(/obj/structure/closet/body_bag/lost_crew/with_body)

	for(var/closet_type in all_closets)
		var/obj/structure/closet/closet = allocate(closet_type)
		if(QDELETED(closet)) // this is here because the emcloset subtype has a chance of returning a qdel hint on initialize
			continue

		// Copy is necessary otherwise closet.contents - immediate_contents returns an empty list
		var/list/immediate_contents = closet.contents.Copy()
		closet.PopulateContents()
		var/contents_len = length(closet.contents)

		if(contents_len > closet.storage_capacity)
			TEST_FAIL("Initial Contents of [closet.type] ([contents_len]) exceed its storage capacity ([closet.storage_capacity]).")

		for (var/obj/item/item in closet.contents - immediate_contents)
			if (item.type in GLOB.steal_item_handler.objectives_by_path)
				TEST_FAIL("[closet_type] contains a steal objective [item.type] in PopulateContents(). Move it to populate_contents_immediate().")
