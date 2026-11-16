/datum/unit_test/cuffed_item
	abstract_type = /datum/unit_test/cuffed_item
	var/mob/living/carbon/human/consistent/owner
	var/obj/item/storage/briefcase/briefcase

/// Cuffs a briefcase to the right wrist of a new mob, then drops it on the floor. Returns FALSE if the cuffing failed.
/datum/unit_test/cuffed_item/proc/drop_briefcase_cuffed_to_right_wrist()
	owner = EASY_ALLOCATE()
	briefcase = EASY_ALLOCATE()
	var/obj/item/restraints/handcuffs/cuffs = EASY_ALLOCATE()
	owner.swap_hand(LEFT_HANDS, silent = TRUE)
	owner.put_in_l_hand(cuffs)
	owner.put_in_r_hand(briefcase)
	if(!owner.apply_status_effect(/datum/status_effect/cuffed_item, briefcase, cuffs))
		return FALSE
	owner.dropItemToGround(briefcase)
	return TRUE

/// Tests that a cuffed item lying on the floor is dragged into the tile its owner leaves
/datum/unit_test/cuffed_item/dragged_after_owner

/datum/unit_test/cuffed_item/dragged_after_owner/Run()
	TEST_ASSERT(drop_briefcase_cuffed_to_right_wrist(), "Failed to cuff the briefcase to the owner.")
	var/turf/first_step = get_step(owner, EAST)
	owner.Move(first_step, EAST)
	owner.Move(get_step(owner, EAST), EAST)
	TEST_ASSERT_EQUAL(briefcase.loc, first_step, "The briefcase was not dragged into the tile its owner left.")

/// Tests that a mob holding someone's cuffed item is not dragged into the tile the owner's pulled object moves into
/datum/unit_test/cuffed_item/holder_does_not_block_pull

/datum/unit_test/cuffed_item/holder_does_not_block_pull/Run()
	TEST_ASSERT(drop_briefcase_cuffed_to_right_wrist(), "Failed to cuff the briefcase to the owner.")
	var/turf/start = run_loc_floor_bottom_left
	var/mob/living/carbon/human/consistent/holder = allocate(/mob/living/carbon/human/consistent, locate(start.x, start.y + 1, start.z))
	holder.put_in_hands(briefcase)
	var/turf/owner_start = locate(start.x + 1, start.y, start.z)
	owner.forceMove(owner_start)
	var/obj/structure/closet/crate/crate = allocate(/obj/structure/closet/crate, start)
	owner.start_pulling(crate)

	owner.Move(get_step(owner, EAST), EAST)
	TEST_ASSERT_EQUAL(crate.loc, owner_start, "The pulled crate did not follow the owner because the holder of the cuffed item took its tile.")

/// Tests that a cuffed item goes into a closet with its owner, without a tether, and comes back out with them
/datum/unit_test/cuffed_item/follows_owner_through_closet

/datum/unit_test/cuffed_item/follows_owner_through_closet/Run()
	TEST_ASSERT(drop_briefcase_cuffed_to_right_wrist(), "Failed to cuff the briefcase to the owner.")
	var/obj/structure/closet/closet = allocate(/obj/structure/closet, owner.loc)
	owner.forceMove(closet)
	TEST_ASSERT_EQUAL(briefcase.loc, closet, "The briefcase did not follow its owner into the closet.")
	TEST_ASSERT_NULL(briefcase.GetComponent(/datum/component/chained_together), "The briefcase kept a tether while sharing the closet with its owner.")
	TEST_ASSERT_NULL(closet.GetComponent(/datum/component/chained_together), "The closet got a tether while holding both the briefcase and its owner.")

	owner.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT_EQUAL(briefcase.loc, run_loc_floor_bottom_left, "The briefcase did not follow its owner out of the closet.")

/// Tests that deleting the owner of a cuffed item lying on the floor removes the tether cleanly
/datum/unit_test/cuffed_item/owner_deleted_while_tethered

/datum/unit_test/cuffed_item/owner_deleted_while_tethered/Run()
	TEST_ASSERT(drop_briefcase_cuffed_to_right_wrist(), "Failed to cuff the briefcase to the owner.")
	qdel(owner)
	TEST_ASSERT_NULL(briefcase.GetComponent(/datum/component/chained_together), "The briefcase kept its tether after its owner was deleted.")

/// Tests that the strip menu offers to remove the cuffs on the hand of the cuffed wrist while that hand is empty
/datum/unit_test/cuffed_item/strip_menu_uncuffs_from_empty_hand

/datum/unit_test/cuffed_item/strip_menu_uncuffs_from_empty_hand/Run()
	TEST_ASSERT(drop_briefcase_cuffed_to_right_wrist(), "Failed to cuff the briefcase to the owner.")
	var/datum/strippable_item/hand/right_hand = GLOB.strippable_human_items[STRIPPABLE_ITEM_RHAND]
	TEST_ASSERT(STRIPPABLE_ALT_ACTION_REMOVE_ITEM_CUFFS in right_hand.get_alternate_actions(owner, owner, null), "The empty right hand did not offer to remove the cuffs of the briefcase on the floor.")
