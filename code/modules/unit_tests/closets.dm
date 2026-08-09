/// Checks that the length of the initial contents of a closet doesn't exceed its storage capacity.
/// Also checks that nothing inside that isn't immediate is a steal objective.
/datum/unit_test/closet_contents

/datum/unit_test/closet_contents/Run()
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

/// Tests whether two closet subtypes(body_bag & crate) successfully perform their functions, and their parent's.
/datum/unit_test/closet_opening

/datum/unit_test/closet_opening/Run()
	var/mob/living/carbon/human/consistent/placer = EASY_ALLOCATE()
	var/obj/structure/closet/crate/secure/locked_crate = allocate(/obj/structure/closet/crate/secure, get_step(run_loc_floor_bottom_left, NORTH))
	var/obj/structure/closet/body_bag/corpse_bag = allocate(/obj/structure/closet/body_bag, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/item/food/cookie/placing_tester = EASY_ALLOCATE()
	var/obj/item/card/id/advanced/gold/captains_spare/cool_card = EASY_ALLOCATE()

	placer.equip_to_slot(cool_card, ITEM_SLOT_ID)
	placer.put_in_active_hand(placing_tester)
	locked_crate.req_access = list(ACCESS_CAPTAIN)

	click_wrapper(placer, locked_crate)
	TEST_ASSERT_NOTNULL(placer.get_active_held_item(), "Successfully placed item in closed, locked crate")

	placer.swap_hand()
	click_wrapper(placer, locked_crate)
	TEST_ASSERT(!locked_crate.locked, "Was unable to unlock locked crate despite adequate access")

	click_wrapper(placer, locked_crate)
	TEST_ASSERT(locked_crate.opened, "Was unable to open unlocked crate")

	placer.swap_hand()
	click_wrapper(placer, locked_crate)
	TEST_ASSERT(placing_tester in locked_crate.loc, "Was unable to place item in open crate")

	click_wrapper(placer, locked_crate)
	TEST_ASSERT(placing_tester in locked_crate, "Closing a crate with an item on it did not move it within the crate")

	click_wrapper(placer, locked_crate, list(RIGHT_CLICK = TRUE, BUTTON = RIGHT_CLICK))
	TEST_ASSERT(locked_crate.locked, "Right-clicking a crate with adequate access did not lock it")

	// Begin bodybag

	click_wrapper(placer, corpse_bag)
	TEST_ASSERT(corpse_bag.opened, "Could not open a placed bodybag")

	placer.put_in_active_hand(placing_tester, TRUE)
	click_wrapper(placer, corpse_bag)
	TEST_ASSERT(placing_tester in corpse_bag.loc, "Could not place item on opened bodybag")

	click_wrapper(placer, corpse_bag)
	TEST_ASSERT(placing_tester in corpse_bag, "Closing a bodybag on an item did not move it within the bodybag")
