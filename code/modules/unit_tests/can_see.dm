/// Unit test to make sure can_see is working properly
/datum/unit_test/can_see_test

/datum/unit_test/can_see_test/Run()
	var/mob/living/carbon/human/observer = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/to_be_seen = allocate(/mob/living/carbon/human/consistent)
	if(get_dist(observer, to_be_seen) <= 1) //move them apart
		observer.forceMove(run_loc_floor_bottom_left)
		to_be_seen.forceMove(run_loc_floor_top_right)
	TEST_ASSERT(can_see(observer, to_be_seen, get_dist(observer, to_be_seen)), "can_see returned false despite dummies being able to see one another!")
