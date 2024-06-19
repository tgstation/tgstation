/// A screenshot test for making sure invisible limbs function, keeping them clothed so we know they're there.
/datum/unit_test/screenshot_saturnx

/datum/unit_test/screenshot_saturnx/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/dummy/consistent) //we don't use a dummy as they have no organs
	human.equipOutfit(/datum/outfit/job/assistant/consistent, visualsOnly = TRUE)

	var/datum/reagent/drug/saturnx/saturnx_reagent = new()

	saturnx_reagent.expose_atom(human, 15)
	saturnx_reagent.turn_man_invisible(human, requires_liver = FALSE) //immediately turn us invisible

	test_screenshot("invisibility", get_flat_icon_for_all_directions(human, no_anim = FALSE))
