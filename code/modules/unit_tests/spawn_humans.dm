/datum/unit_test/spawn_humans/Run()
	var/locs = block(run_loc_floor_bottom_left, run_loc_floor_top_right)

	for(var/I in 1 to 5)
		allocate(/mob/living/carbon/human/consistent, pick(locs))

	sleep(5 SECONDS)

/// Tests [/mob/living/carbon/human/proc/setup_organless_effects], specifically that they aren't applied when init is done
/datum/unit_test/human_default_traits

/datum/unit_test/human_default_traits/Run()
	var/mob/living/carbon/human/consistent/dummy = allocate(/mob/living/carbon/human/consistent)
	TEST_ASSERT(!HAS_TRAIT_FROM(dummy, TRAIT_AGEUSIA, NO_TONGUE_TRAIT), "Dummy has ageusia on init, when it should've been removed by its default tongue.")
	TEST_ASSERT(!dummy.is_blind_from(NO_EYES), "Dummy is blind on init,  when it should've been removed by its default eyes.")
