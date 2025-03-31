/// Regression test for timestop being a 3x3 instead of a 5x5
/datum/unit_test/timestop

/datum/unit_test/timestop/Run()
	var/mob/living/carbon/human/dio = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/kakyoin = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/jotaro = allocate(/mob/living/carbon/human/consistent)

	var/turf/center = run_loc_floor_bottom_left
	var/turf/in_range = locate(center.x + 2, center.y + 2, center.z)
	var/turf/out_of_range = locate(in_range.x + 1, in_range.y + 1, in_range.z)

	dio.forceMove(center)
	kakyoin.forceMove(in_range)
	jotaro.forceMove(out_of_range)

	var/datum/action/cooldown/spell/timestop/timestop = new(dio)
	timestop.spell_requirements = NONE
	timestop.Grant(dio)
	timestop.Trigger()
	var/obj/effect/timestop/time_effect = locate() in center
	TEST_ASSERT(time_effect, "Failed to create timestop effect")
	sleep(0.1 SECONDS) // timestop is invoked async so let's just wait

	TEST_ASSERT(!dio.IsStun(), "Timestopper should not have frozen themselves when using timestop")
	TEST_ASSERT(kakyoin.IsStun(), "Timestopper should have frozen the target within 2 tiles of range when using timestop")
	TEST_ASSERT(!jotaro.IsStun(), "Timestopper should not have frozen the target outside of 2 tiles of range when using timestop")

	// cleanup
	qdel(time_effect)
