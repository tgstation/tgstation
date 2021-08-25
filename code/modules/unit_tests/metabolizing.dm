/datum/unit_test/metabolization/Run()
	// Pause natural mob life so it can be handled entirely by the test
	SSmobs.pause()

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)

	for (var/reagent_type in subtypesof(/datum/reagent))
		if(reagent_type in GLOB.fake_reagent_blacklist)
			continue
		test_reagent(human, reagent_type)

/datum/unit_test/metabolization/proc/test_reagent(mob/living/carbon/C, reagent_type)
	C.reagents.add_reagent(reagent_type, 10)
	C.reagents.metabolize(C, SSMOBS_DT, 0, can_overdose = TRUE)
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
	pill.reagents.add_reagent(meth, 1.9 * initial(meth.metabolization_rate) * SSMOBS_DT)
	pill.attack(user, user)

	user.Life(SSMOBS_DT)

	TEST_ASSERT(user.reagents.has_reagent(meth), "User does not have meth in their system after consuming it")
	TEST_ASSERT(user.has_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine), "User consumed meth, but did not gain movespeed modifier")

	user.Life(SSMOBS_DT)

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

	var/datum/mind/pill_mind = new /datum/mind("Mothcocks")
	pill_mind.active = TRUE
	pill_mind.transfer_to(pill_user)

	var/datum/mind/syringe_mind = new /datum/mind("Mothcocks")
	syringe_mind.active = TRUE
	syringe_mind.transfer_to(syringe_user)

	var/datum/mind/pill_syringe_mind = new /datum/mind("Mothcocks")
	pill_syringe_mind.active = TRUE
	pill_syringe_mind.transfer_to(pill_syringe_user)

	var/obj/item/reagent_containers/pill/pill = allocate(/obj/item/reagent_containers/pill)
	var/obj/item/reagent_containers/pill/pill_two = allocate(/obj/item/reagent_containers/pill)

	var/obj/item/reagent_containers/syringe/syringe = allocate(/obj/item/reagent_containers/syringe)

	var/datum/reagent/drug/methamphetamine/meth = allocate(/datum/reagent/drug/methamphetamine)

	var/addiction_type_to_check

	for(var/key in meth.addiction_types)
		addiction_type_to_check = key //idk how to do this otherwise

	// Let's start with stomach metabolism
	pill.reagents.add_reagent(meth.type, 5)
	pill.attack(pill_user, pill_user)

	// Set the metabolism efficiency to 1.0 so it transfers all reagents to the body in one go.
	var/obj/item/organ/stomach/pill_belly = pill_user.getorganslot(ORGAN_SLOT_STOMACH)
	pill_belly.metabolism_efficiency = 1

	pill_user.Life()

	TEST_ASSERT(pill_user.mind.addiction_points[addiction_type_to_check], "User did not gain addiction points after metabolizing meth")

	// Then injected metabolism
	syringe.volume = 5
	syringe.amount_per_transfer_from_this = 5
	syringe.reagents.add_reagent(meth.type, 5)
	syringe.melee_attack_chain(syringe_user, syringe_user)

	syringe_user.Life()

	TEST_ASSERT(syringe_user.mind.addiction_points[addiction_type_to_check], "User did not gain addiction points after metabolizing meth")

	// One half syringe
	syringe.reagents.remove_all()
	syringe.volume = 5
	syringe.amount_per_transfer_from_this = 5
	syringe.reagents.add_reagent(meth.type, (5 * 0.5) + 1)

	// One half pill
	pill_two.reagents.add_reagent(meth.type, (5 * 0.5) + 1)
	pill_two.attack(pill_syringe_user, pill_syringe_user)
	syringe.melee_attack_chain(pill_syringe_user, pill_syringe_user)

	// Set the metabolism efficiency to 1.0 so it transfers all reagents to the body in one go.
	pill_belly = pill_syringe_user.getorganslot(ORGAN_SLOT_STOMACH)
	pill_belly.metabolism_efficiency = 1

	pill_syringe_user.Life()

	TEST_ASSERT(pill_syringe_user.mind.addiction_points[addiction_type_to_check], "User did not gain addiction points after metabolizing meth")

/datum/unit_test/addictions/Destroy()
	SSmobs.ignite()
	return ..()
