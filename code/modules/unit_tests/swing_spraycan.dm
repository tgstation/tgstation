/datum/unit_test/spraypainting

/datum/unit_test/spraypainting/Run()
	var/mob/living/carbon/human/artist = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/toy/crayon/spraycan/can = allocate(/obj/item/toy/crayon/spraycan)
	var/start_with = can.charges

	artist.put_in_active_hand(can, forced = TRUE)
	click_wrapper(artist, get_turf(artist))

	// Try to pray with a capped spraycan.
	TEST_ASSERT_EQUAL(start_with, can.charges, "Spraypaint sprayed paint while capped.")
	// Uncap it
	can.AltClick(artist)
	TEST_ASSERT(!can.is_capped, "Spraypaint did not uncap when alt-clicked.")
	// Try to spray with an uncapped spraycan.
	TEST_ASSERT_NOTEQUAL(start_with, can.charges, "Spraypaint did not spray any paint when clicking on a turf with it.")
