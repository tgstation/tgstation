/datum/unit_test/metabolization/Run()
	// Pause natural mob life so it can be handled entirely by the test
	SSmobs.pause()

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)

	for (var/reagent_type in subtypesof(/datum/reagent))
		test_reagent(human, reagent_type)

/datum/unit_test/metabolization/proc/test_reagent(mob/living/carbon/C, reagent_type)
	C.reagents.add_reagent(reagent_type, 10)
	C.reagents.metabolize(C, can_overdose = TRUE)
	C.reagents.clear_reagents()

/datum/unit_test/metabolization/Destroy()
	SSmobs.ignite()
	return ..()

/datum/unit_test/on_mob_end_metabolize/Run()
	SSmobs.pause()

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

/datum/unit_test/on_mob_end_metabolize/Destroy()
	SSmobs.ignite()
	return ..()

/datum/unit_test/addictions/Run()
	SSmobs.pause()

	var/mob/living/carbon/human/pill_user = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/syringe_user = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/pill_syringe_user = allocate(/mob/living/carbon/human)

	var/obj/item/reagent_containers/pill/pill = allocate(/obj/item/reagent_containers/pill)
	var/obj/item/reagent_containers/pill/pill_two = allocate(/obj/item/reagent_containers/pill)

	var/obj/item/reagent_containers/syringe/syringe = allocate(/obj/item/reagent_containers/syringe)

	var/datum/reagent/drug/methamphetamine/meth = allocate(/datum/reagent/drug/methamphetamine)


	// Let's start with stomach metabolism
	pill.reagents.add_reagent(meth.type, meth.addiction_threshold)
	pill.attack(pill_user, pill_user)

	// Set the metabolism efficiency to 1.0 so it transfers all reagents to the body in one go.
	var/obj/item/organ/stomach/pill_belly = pill_user.getorganslot(ORGAN_SLOT_STOMACH)
	pill_belly.metabolism_efficiency = 1

	pill_user.Life()

	TEST_ASSERT(pill_user.reagents.addiction_list && is_type_in_list(meth, pill_user.reagents.addiction_list), "User is not addicted to meth after ingesting the addiction threshold")

	// Then injected metabolism
	syringe.volume = meth.addiction_threshold
	syringe.amount_per_transfer_from_this = meth.addiction_threshold
	syringe.reagents.add_reagent(meth.type, meth.addiction_threshold)

	syringe.mode = SYRINGE_INJECT
	syringe_user.set_combat_mode(TRUE)
	syringe.afterattack(syringe_user, syringe_user, TRUE)

	syringe_user.Life()

	TEST_ASSERT(syringe_user.reagents.addiction_list && is_type_in_list(meth, syringe_user.reagents.addiction_list), "User is not addicted to meth after injecting the addiction threshold")

	// One half syringe
	syringe.reagents.remove_all()
	syringe.volume = meth.addiction_threshold
	syringe.amount_per_transfer_from_this = meth.addiction_threshold
	syringe.reagents.add_reagent(meth.type, (meth.addiction_threshold * 0.5) + 1)

	// One half pill
	pill_two.reagents.add_reagent(meth.type, (meth.addiction_threshold * 0.5) + 1)
	pill_two.attack(pill_syringe_user, pill_syringe_user)

	pill_syringe_user.set_combat_mode(TRUE)
	syringe.mode = SYRINGE_INJECT
	syringe.afterattack(pill_syringe_user, pill_syringe_user, TRUE)

	// Set the metabolism efficiency to 1.0 so it transfers all reagents to the body in one go.
	pill_belly = pill_syringe_user.getorganslot(ORGAN_SLOT_STOMACH)
	pill_belly.metabolism_efficiency = 1

	pill_syringe_user.Life()

	TEST_ASSERT(pill_syringe_user.reagents.addiction_list && is_type_in_list(meth, pill_syringe_user.reagents.addiction_list), "User is not addicted to meth after injecting and ingesting half the addiction threshold each")

/datum/unit_test/addictions/Destroy()
	SSmobs.ignite()
	return ..()
