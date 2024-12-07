/// Tests spray painting the ground to create graffiti.
/datum/unit_test/spraypainting

/datum/unit_test/spraypainting/Run()
	var/mob/living/carbon/human/consistent/artist = EASY_ALLOCATE()
	var/obj/item/toy/crayon/spraycan/can = EASY_ALLOCATE()
	var/turf/spray_turf = get_turf(artist)
	artist.put_in_active_hand(can, forced = TRUE)

	// Try to spray with a capped spraycan.
	click_wrapper(artist, spray_turf)
	TEST_ASSERT_EQUAL(can.charges, can.charges_left, "Spraypaint sprayed paint while capped.")
	// Uncap it
	click_wrapper(artist, can, list(ALT_CLICK = TRUE, BUTTON = ALT_CLICK))
	TEST_ASSERT(!can.is_capped, "Spraypaint did not uncap when alt-clicked.")
	// Try to spray with an uncapped spraycan.
	click_wrapper(artist, spray_turf)
	TEST_ASSERT_NOTEQUAL(can.charges, can.charges_left, "Spraypaint did not spray any paint when clicking on a turf with it.")

	// Cleanup
	for(var/obj/effect/decal/cleanable/crayon/made_art in spray_turf)
		qdel(made_art)
