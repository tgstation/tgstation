/// Tests the ability to load syringe into a syringe gun
/datum/unit_test/load_syringe

/datum/unit_test/load_syringe/Run()
	var/mob/living/carbon/human/chemist = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/gun/syringe/syringe_gun = allocate(/obj/item/gun/syringe)
	var/obj/item/reagent_containers/syringe/syringe = allocate(/obj/item/reagent_containers/syringe)

	chemist.put_in_active_hand(syringe, forced = TRUE)
	chemist.put_in_inactive_hand(syringe_gun, forced = TRUE)

	click_wrapper(chemist, syringe_gun)

	TEST_ASSERT_EQUAL(syringe.loc, syringe_gun, "Syringe was not added to syringe gun when clicking on it to load it.")
