/// Tests that airlocks can be closed by clicking on the floor, as [/datum/component/redirect_attack_hand_from_turf ] dictates
/datum/unit_test/door_click

/datum/unit_test/door_click/Run()
	var/mob/living/carbon/human/tider = allocate(/mob/living/carbon/human/consistent)
	var/obj/machinery/door/airlock/public/glass/door = allocate(/obj/machinery/door/airlock/public/glass)

	tider.forceMove(locate(door.x + 1, door.y, door.z))
	door.open() // this sleeps we just have to cope

	click_wrapper(tider, get_turf(door))
	TEST_ASSERT(door.density, "Airlock could not be opened by clicking on its floor below, \
		as expected of behavior added by /datum/component/redirect_attack_hand_from_turf.")
