// Unit tests for recycler machine.

/// Tests that holographic items are properly processed - deleted while preserving real contents.
/datum/unit_test/recycler_hologram

/datum/unit_test/recycler_hologram_processing/Run()
	var/obj/machinery/recycler/recycler = allocate(/obj/machinery/recycler/deathtrap, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/item/storage/box/hologram_container = allocate(/obj/item, run_loc_floor_bottom_left)
	// Create a holographic box with real contents.
	hologram_container.flags_1 |= HOLOGRAM_1
	// Add real, non-holographic cookie to the hologram box.
	var/obj/item/food/cookie/real_cookie = allocate(/obj/item/food/cookie, hologram_container)
	// Process the hologram through the recycler.
	hologram_container.forceMove(get_turf(recycler))
	// Check that hologram was properly deleted.
	TEST_ASSERT(QDELETED(hologram_container), "Hologram item was not deleted after processing")
	// Check that real items were moved to recycler location (not deleted).
	TEST_ASSERT(!QDELETED(real_cookie), "Non-holographic contents of holographic item was incorrectly deleted with hologram")
	TEST_ASSERT_EQUAL(real_cookie.loc, get_turf(recycler), "Non-holographic contents of holographic item was not moved to recycler location")

/// Tests that recycler properly handles indestructible items.
/datum/unit_test/recycler_indestructible_item

/datum/unit_test/recycler_indestructible_items/Run()
	var/obj/machinery/recycler/recycler = allocate(/obj/machinery/recycler/deathtrap, get_step(run_loc_floor_bottom_left, EAST))
	// Create indestructible cookie.
	var/obj/item/food/cookie/indestructible_cookie = allocate(/obj/item, run_loc_floor_bottom_left)
	indestructible_cookie.resistance_flags |= INDESTRUCTIBLE
	// Try to process indestructible cookie.
	indestructible_cookie.forceMove(get_turf(recycler))
	// Cookie should still exist.
	TEST_ASSERT(!QDELETED(indestructible_cookie), "Indestructible item was recycled")

/// Tests that brains trigger safety mode in the recycler
/datum/unit_test/recycler_brain_safety

/datum/unit_test/recycler_brain_safety/Run()
	var/obj/machinery/recycler/recycler = allocate(/obj/machinery/recycler,  get_step(run_loc_floor_bottom_left, EAST))
	var/mob/living/brain/test_brain = allocate(/mob/living/brain, run_loc_floor_bottom_left)
	// Process brain - should trigger safety mode.
	test_brain.forceMove(get_turf(recycler))
	// Should enter safety mode.
	TEST_ASSERT(recycler.safety_mode, "Recycler did not enter safety mode when processing brain")
	// Brain should not be deleted.
	TEST_ASSERT(!QDELETED(test_brain), "Brain was incorrectly deleted in safety mode")

/// Tests that MMI with brain triggers safety mode.
/datum/unit_test/recycler_mmi_with_brain_safety

/datum/unit_test/recycler_mmi_with_brain_safety/Run()
	var/obj/machinery/recycler/recycler = allocate(/obj/machinery/recycler,  get_step(run_loc_floor_bottom_left, EAST))
	var/obj/item/mmi/test_mmi = allocate(/obj/item/mmi, run_loc_floor_bottom_left)
	var/mob/living/brain/test_brain = allocate(/mob/living/brain)
	test_mmi.brain = test_brain
	test_brain.forceMove(test_mmi)
	// Process MMI with brain - should trigger safety mode.
	test_mmi.forceMove(get_turf(recycler))
	// Should enter safety mode.
	TEST_ASSERT(recycler.safety_mode, "Recycler did not enter safety mode when processing MMI with brain")
	// MMI should not be deleted.
	TEST_ASSERT(!QDELETED(test_mmi), "MMI with brain was incorrectly deleted in safety mode")
	// Brain should still be intact inside MMI.
	TEST_ASSERT(!QDELETED(test_mmi.brain), "Brain was deleted during safety mode processing")
