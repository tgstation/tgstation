/// Test that people can move pulled objects by clicking distant turfs or decals
/datum/unit_test/move_pulled
	abstract_type = /datum/unit_test/move_pulled

/datum/unit_test/move_pulled/Run()
	var/mob/living/carbon/human/consistent/puller = allocate(__IMPLIED_TYPE__)
	var/obj/structure/closet/crate/crate = allocate(__IMPLIED_TYPE__)

	puller.start_pulling(crate)

	TEST_ASSERT(puller.pulling == crate, "The puller is not pulling the crate.")

	var/atom/first_target = get_first_target(puller)
	click_wrapper(puller, first_target)

	TEST_ASSERT(crate.loc == run_loc_floor_bottom_left, "The crate should not have moved from clicking on the crate's turf.")

	var/atom/second_target = get_second_target(puller)
	click_wrapper(puller, second_target)

	TEST_ASSERT(crate.loc != run_loc_floor_bottom_left, "The crate should have moved in the direction of the top right turf.")
	TEST_ASSERT(crate.loc == get_turf(second_target), "The crate should be located at the northeast of the puller.")

/datum/unit_test/move_pulled/proc/get_first_target(mob/living/puller)
	CRASH("Unimplemented get_first_target in move_pulled unit test")

/datum/unit_test/move_pulled/proc/get_second_target(mob/living/puller)
	CRASH("Unimplemented get_second_target in move_pulled unit test")

/// Try to move a pulled object to the turf below us, then to the opposite corner
/datum/unit_test/move_pulled/to_turf

/datum/unit_test/move_pulled/to_turf/get_first_target(mob/living/puller)
	return run_loc_floor_bottom_left

/datum/unit_test/move_pulled/to_turf/get_second_target(mob/living/puller)
	return get_step(puller, NORTHEAST)

/// Try to move a pulled object to a decal below us, then to a decal in the opposite corner
/datum/unit_test/move_pulled/to_decal

/datum/unit_test/move_pulled/to_decal/get_first_target(mob/living/puller)
	return allocate(/obj/effect/decal/cleanable/blood, run_loc_floor_bottom_left)

/datum/unit_test/move_pulled/to_decal/get_second_target(mob/living/puller)
	return allocate(/obj/effect/decal/cleanable/blood, get_step(puller, NORTHEAST))
