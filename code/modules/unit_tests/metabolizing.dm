// Regression test for https://github.com/tgstation/tgstation/issues/52333
/datum/unit_test/colorful_reagent_regression/Run()
	// Pause natural life processing
	SSmobs.pause()

	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human)
	H.reagents.add_reagent(/datum/reagent/colorful_reagent, 10)
	TEST_ASSERT_EQUAL(H.reagents.get_reagent_amount(/datum/reagent/colorful_reagent), 10, "Colorful reagent wasn't 10 when initially giving it to human.")
	H.reagents.metabolize(can_overdose = TRUE)
	TEST_ASSERT(H.reagents.get_reagent_amount(/datum/reagent/colorful_reagent) < 10, "Colorful reagent was still 10 after metabolization.")

/datum/unit_test/colorful_reagent_regression/Destroy()
	SSmobs.ignite()
	return ..()
