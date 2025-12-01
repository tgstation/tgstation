/datum/unit_test/move_pulled
	abstract_type = /datum/unit_test/move_pulled

/datum/unit_test/move_pulled/Run()
	var/mob/living/carbon/human/consistent/puller = allocate(__IMPLIED_TYPE__)
	var/obj/structure/closet/crate/crate = allocate(__IMPLIED_TYPE__)

	puller.start_pulling(crate)

	TEST_ASSERT(puller.pulling == crate, "The puller is not pulling the crate.")

	click_wrapper(puller, get_first_target())

	TEST_ASSERT(crate.loc == run_loc_floor_bottom_left, "The crate should have moved from clicking on the crate's turf.")

	click_wrapper(puller, get_second_target())

	TEST_ASSERT(crate.loc != run_loc_floor_bottom_left, "The crate should have moved in the direction of the top right turf.")
	TEST_ASSERT(crate.loc == get_step(puller, NORTHEAST), "The crate should be located at the northeast of the puller.")

/datum/unit_test/move_pulled/proc/get_first_target()
	CRASH("Unimplemented get_first_target in move_pulled unit test")

/datum/unit_test/move_pulled/proc/get_second_target()
	CRASH("Unimplemented get_first_target in move_pulled unit test")

/// Try to move a pulled object to the turf below us, then to the opposite corner
/datum/unit_test/move_pulled/to_turf

/datum/unit_test/move_pulled/to_turf/get_first_target()
	return run_loc_floor_bottom_left

/datum/unit_test/move_pulled/to_turf/get_second_target()
	return run_loc_floor_top_right

/// Try to move a pulled object to a decal below us, then to a decal in the opposite corner
/datum/unit_test/move_pulled/to_decal

/datum/unit_test/move_pulled/to_decal/get_first_target()
	return allocate(/obj/effect/decal/cleanable/blood, run_loc_floor_bottom_left)

/datum/unit_test/move_pulled/to_decal/get_second_target()
	return allocate(/obj/effect/decal/cleanable/blood, run_loc_floor_top_right)
