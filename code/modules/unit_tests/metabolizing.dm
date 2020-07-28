/datum/unit_test/metabolization/Run()
	// Pause natural mob life so it can be handled entirely by the test
	SSmobs.pause()

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/monkey/monkey = allocate(/mob/living/carbon/monkey)

	for (var/reagent_type in subtypesof(/datum/reagent))
		test_reagent(human, reagent_type)
		test_reagent(monkey, reagent_type)

/datum/unit_test/metabolization/proc/test_reagent(mob/living/carbon/C, reagent_type)
	C.reagents.add_reagent(reagent_type, 10)
	C.reagents.metabolize(C, can_overdose = TRUE)
	C.reagents.clear_reagents()

/datum/unit_test/metabolization/Destroy()
	SSmobs.ignite()
	return ..()
