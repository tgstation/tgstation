/// Tests 100 stamina damage = stamcrit
/datum/unit_test/stamcrit
	priority = TEST_LONGER

/datum/unit_test/stamcrit/Run()
	var/mob/living/carbon/human/consistent/tider = allocate(__IMPLIED_TYPE__)
	tider.stamina_regen_time = 0.2 SECONDS
	tider.adjustStaminaLoss(99)
	TEST_ASSERT(!tider.has_status_effect(/datum/status_effect/incapacitating/stamcrit), "Stamcrit should not be applied at 99 stamina damage")
	tider.adjustStaminaLoss(1)
	TEST_ASSERT(tider.has_status_effect(/datum/status_effect/incapacitating/stamcrit), "Stamcrit should be applied at 100 stamina damage")
	sleep(tider.stamina_regen_time * 2)
	TEST_ASSERT(!tider.has_status_effect(/datum/status_effect/incapacitating/stamcrit), "Stamcrit should be removed after regen time")

/// Tests stamina regen after the set time
/datum/unit_test/stam_regen
	priority = TEST_LONGER

/datum/unit_test/stam_regen/Run()
	var/mob/living/carbon/human/consistent/tider = allocate(__IMPLIED_TYPE__)
	tider.stamina_regen_time = 0.2 SECONDS
	tider.adjustStaminaLoss(50)
	sleep(tider.stamina_regen_time * 2)
	TEST_ASSERT_EQUAL(tider.getStaminaLoss(), 0, "Stamina should be fully regenerated after regen time")
