/// Regression test for timestop being a 3x3 instead of a 5x5
/datum/unit_test/timestop

/datum/unit_test/timestop/Run()
	var/mob/living/carbon/human/dio = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/kakyoin = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/jotaro = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/johnathan = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/basic/guardian/the_world = allocate(/mob/living/basic/guardian)
	var/mob/living/basic/guardian/star_platinum = allocate(/mob/living/basic/guardian)
	var/mob/living/basic/guardian/heirophant_green = allocate(/mob/living/basic/guardian)

	the_world.set_summoner(dio)
	star_platinum.set_summoner(jotaro)
	heirophant_green.set_summoner(kakyoin)

	var/turf/center = run_loc_floor_bottom_left
	var/turf/in_range = locate(center.x + 2, center.y + 2, center.z)
	var/turf/out_of_range = locate(in_range.x + 1, in_range.y + 1, in_range.z)

	dio.forceMove(center)
	kakyoin.forceMove(in_range)
	jotaro.forceMove(in_range)
	johnathan.forceMove(out_of_range)

	the_world.manifest(TRUE)
	star_platinum.manifest(TRUE)
	heirophant_green.manifest(TRUE)

	TEST_ASSERT_EQUAL(the_world.loc, dio.loc, "Holoparasite failed to manifest")

	var/datum/action/cooldown/spell/timestop/other_timestop = new(jotaro)
	other_timestop.Grant(jotaro)

	var/datum/action/cooldown/spell/timestop/timestop = new(dio)
	timestop.spell_requirements = NONE
	timestop.Grant(dio)
	timestop.Trigger()

	var/obj/effect/timestop/time_effect = locate() in center
	TEST_ASSERT_NOTNULL(time_effect, "Failed to create timestop effect")
	sleep(0.1 SECONDS) // timestop is invoked async so let's give it a moment

	TEST_ASSERT(!HAS_TRAIT_FROM(dio, TRAIT_IMMOBILIZED, TIMESTOP_TRAIT), "Timestopper should not have frozen themselves when using timestop")
	TEST_ASSERT(HAS_TRAIT_FROM(kakyoin, TRAIT_IMMOBILIZED, TIMESTOP_TRAIT), "Timestopper should have frozen the target within 2 tiles of range when using timestop")
	TEST_ASSERT(!HAS_TRAIT_FROM(johnathan, TRAIT_IMMOBILIZED, TIMESTOP_TRAIT), "Timestopper should not have frozen the target outside of 2 tiles of range when using timestop")
	TEST_ASSERT(!HAS_TRAIT_FROM(jotaro, TRAIT_IMMOBILIZED, TIMESTOP_TRAIT), "Timestopper should not have frozen another timestopper when using timestop")
	TEST_ASSERT(!HAS_TRAIT_FROM(the_world, TRAIT_IMMOBILIZED, TIMESTOP_TRAIT), "Timestopper should not have frozen their own holoparasite when using timestop")
	TEST_ASSERT(!HAS_TRAIT_FROM(star_platinum, TRAIT_IMMOBILIZED, TIMESTOP_TRAIT), "Timestopper should not have frozen a holoparsite from another timestopper when using timestop")
	TEST_ASSERT(HAS_TRAIT_FROM(heirophant_green, TRAIT_IMMOBILIZED, TIMESTOP_TRAIT), "Timestopper shold not frozen a holoparsite from a non-timestopper when using timestop")

	// cleanup
	qdel(time_effect)

	TEST_ASSERT(!HAS_TRAIT_FROM(kakyoin, TRAIT_IMMOBILIZED, TIMESTOP_TRAIT), "Timestop didn't unfreeze the target after the effect expired")
	TEST_ASSERT(!HAS_TRAIT_FROM(heirophant_green, TRAIT_IMMOBILIZED, TIMESTOP_TRAIT), "Timestop didn't unfreeze the target's holoparasite after the effect expired")
