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

/datum/unit_test/on_mob_end_metabolize/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/reagent_containers/pill/pill = allocate(/obj/item/reagent_containers/pill)
	var/datum/reagent/drug/methamphetamine/meth = /datum/reagent/drug/methamphetamine

	// Give them enough meth to be consumed in 2 metabolizations
	pill.reagents.add_reagent(meth, initial(meth.metabolization_rate) * 1.9)
	pill.attack(user, user)

	user.Life()

	TEST_ASSERT(user.reagents.has_reagent(meth), "User does not have meth in their system after consuming it")
	TEST_ASSERT(user.has_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine), "User consumed meth, but did not gain movespeed modifier")

	user.Life()

	TEST_ASSERT(!user.reagents.has_reagent(meth), "User still has meth in their system when it should've finished metabolizing")
	TEST_ASSERT(!user.has_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine), "User still has movespeed modifier despite not containing any more meth")
