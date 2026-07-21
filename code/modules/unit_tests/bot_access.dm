/// Tests whether bots have been made able to bypass access, as well as whether they've been made throwable. None should be at the moment, and if they should be, make an exception
/datum/unit_test/bot_access

/datum/unit_test/bot_access/Run()
	var/list/throwable_bots = list()
	var/list/access_bypassing_bots = list()
	var/obj/machinery/door/airlock/instant/impassable_door = allocate(/obj/machinery/door/airlock/instant, get_step(run_loc_floor_bottom_left, EAST))

	impassable_door.req_access = list("access nothing has")

	var/mob/living/basic/bot/bot_to_check
	for(var/bot_type in valid_subtypesof(/mob/living/basic/bot))
		bot_to_check = allocate(bot_type, run_loc_floor_bottom_left)
		if(bot_to_check.status_flags & CANPUSH)
			throwable_bots += bot_to_check.type
		bot_to_check.Bump(impassable_door)
		if(!impassable_door.density)
			access_bypassing_bots += bot_to_check.type
			impassable_door.close(TRUE)

	if(throwable_bots.len)
		TEST_FAIL("The following bots are throwable: [english_list(throwable_bots)]")

	TEST_ASSERT(!access_bypassing_bots.len, "The following bots bypass access requirements: [english_list(access_bypassing_bots)]")

