/datum/unit_test/rcd/Run()
	var/obj/item/construction/rcd/rcd = allocate(/obj/item/construction/rcd/combat/admin)
	var/mob/living/carbon/human/engineer = allocate(/mob/living/carbon/human)

	engineer.put_in_hands(rcd, forced = TRUE)

	rcd.mode = RCD_MACHINE

	var/list/adjacent_turfs = get_adjacent_open_turfs(engineer)

	if(!length(adjacent_turfs))
		Fail("RCD Test failed - Lack of adjacent open turfs. This may be an issue with the unit test.")

	var/turf/adjacent_turf = adjacent_turfs[1]

	for(var/i in 1 to 10)
		adjacent_turf.rcd_act(engineer, rcd, rcd.mode)

	var/frame_count = 0
	for(var/obj/structure/frame/machine_frame in adjacent_turf.contents)
		frame_count++

	TEST_ASSERT(frame_count != 1, "Expected RCD test to end up with 1 machine frame. It instead created [frame_count] machine frames.")
