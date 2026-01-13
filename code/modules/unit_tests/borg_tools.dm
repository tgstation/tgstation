/datum/unit_test/borg_tools

/datum/unit_test/borg_tools/Run()
	var/mob/living/silicon/robot/ourborg = EASY_ALLOCATE()
	ourborg.model.transform_to(/obj/item/robot_model/engineering, TRUE, FALSE)
	var/turf/targetturf = locate(ourborg.x + 1, ourborg.y, ourborg.z)
	var/obj/item/construction/rtd/borg/rtd = locate(/obj/item/construction/rtd/borg) in ourborg.model
	TEST_ASSERT_NOTNULL(rtd, "Engineering borg lacks an RTD module")
	targetturf.ChangeTurf(/turf/open/floor/plating)
	ourborg.activate_module(rtd)
	ourborg.select_module(1)
	TEST_ASSERT_NOTNULL(ourborg.module_active, "RTD module failed to activate")
	click_wrapper(ourborg, targetturf)
	sleep(rtd.selected_design.cost * 0.15 SECONDS + 0.1 SECONDS)
	TEST_ASSERT(!isplatingturf(targetturf), "Borg RTD was unable to place floor tiling")
	ourborg.deactivate_module(rtd)

	var/obj/item/construction/rcd/borg/rcd = locate(/obj/item/construction/rcd/borg) in ourborg.model
	TEST_ASSERT_NOTNULL(rcd, "Engineering borg lacks an RCD module")
	rcd.delay_mod = 0
	ourborg.activate_module(rcd)
	ourborg.select_module(1)
	TEST_ASSERT_NOTNULL(ourborg.module_active, "RCD module failed to activate")
	click_wrapper(ourborg, targetturf)
	TEST_ASSERT(iswallturf(targetturf), "Borg RCD was unable to create wall")


