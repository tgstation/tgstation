/**
 * Simple unit test to ensure there's no regression in behaviour where machine frames should not be stacked.
 *
 * We attempt to use the RCD to build multiple stacked machine frames on a turf. If we end up with any number that
 * is not equal to 1, this means we've either built no machine frames (bad) or built more than one (regression).
 *
 * If this is successful, we attempt to spawn in some no-density machines that result in machine frames and we run
 * the test again on our turf containing our single frame, deconstructing the machines! This should also not spawn
 * any stacked machine frames.
 */
/datum/unit_test/frame_stacking/Run()
	// First test - RCDs stacking frames.
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

	TEST_ASSERT_EQUAL(frame_count, 1, "Expected RCD machine frame stacking test to end up with exactly 1 machine frame.")

	// Second test - Deconstructing stacked machines to stack frames. We'll recycle our old turf to accomplish this.
	for(var/i in 1 to 10)
		// This should be a type path to a machine with no density, that can be wrenched on a turf with another machine of the same type.
		var/obj/machinery/new_machine = new /obj/machinery/recharger(adjacent_turf)
		new_machine.deconstruct(TRUE)

	frame_count = 0
	for(var/obj/structure/frame/machine_frame in adjacent_turf.contents)
		frame_count++

	TEST_ASSERT_EQUAL(frame_count, 1, "Expected no density machine deconstruction frame stacking test to end up with exactly 1 machine frame.")
