/// Unit test that forces various slips on a mob and checks return values and mob state to see if the slip has likely been successful.
/datum/unit_test/slips

/datum/unit_test/slips/Run()
	// Test just forced slipping, which calls turf slip code as well.
	var/mob/living/carbon/human/mso = allocate(/mob/living/carbon/human/consistent)

	TEST_ASSERT(mso.slip(100) == TRUE, "/mob/living/carbon/human/slip() returned FALSE when TRUE was expected")
	TEST_ASSERT(!!(mso.IsKnockdown()), "/mob/living/carbon/human/slip() failed to knockdown target when knockdown was expected")

	// Test the slipping component, which calls mob slip code. Just for good measure.
	var/mob/living/carbon/human/msos_friend_mso = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	var/obj/item/grown/bananapeel/specialpeel/mso_bane = allocate(/obj/item/grown/bananapeel/specialpeel, get_step(run_loc_floor_bottom_left, EAST))

	msos_friend_mso.Move(get_turf(mso_bane), EAST)
	TEST_ASSERT(!!(msos_friend_mso.IsKnockdown()), "Banana peel which should have slipping component failed to knockdown target when knockdown was expected")
