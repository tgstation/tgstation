/// Tests 100 stamina damage = stamcrit
/datum/unit_test/stamcrit
	priority = TEST_LONGER

/datum/unit_test/stamcrit/Run()
	var/mob/living/carbon/human/consistent/tider = allocate(__IMPLIED_TYPE__)
	tider.stamina_regen_time = 0.2 SECONDS
	var/stamloss_to_reach_crit_threshold = tider.maxHealth
	tider.adjust_stamina_loss(stamloss_to_reach_crit_threshold - 1)
	TEST_ASSERT(!tider.has_status_effect(/datum/status_effect/incapacitating/stamcrit), "Stamcrit should not be applied at [stamloss_to_reach_crit_threshold - 1] stamina damage")
	tider.adjust_stamina_loss(1)
	TEST_ASSERT(tider.has_status_effect(/datum/status_effect/incapacitating/stamcrit), "Stamcrit should be applied at [stamloss_to_reach_crit_threshold] stamina damage")
	sleep(tider.stamina_regen_time * 2)
	TEST_ASSERT(!tider.has_status_effect(/datum/status_effect/incapacitating/stamcrit), "Stamcrit should be removed after regen time")

/// Tests stamina regen after the set time
/datum/unit_test/stam_regen
	priority = TEST_LONGER

/datum/unit_test/stam_regen/Run()
	var/mob/living/carbon/human/consistent/tider = allocate(__IMPLIED_TYPE__)
	tider.stamina_regen_time = 0.2 SECONDS
	tider.adjust_stamina_loss(50)
	sleep(tider.stamina_regen_time * 2)
	TEST_ASSERT_EQUAL(tider.get_stamina_loss(), 0, "Stamina should be fully regenerated after regen time")

/// Tests stam regen timer resets on taking any amount of stamina damage, even if at the stamina damage cap
/datum/unit_test/stam_reset
	var/reset_count = 0

/datum/unit_test/stam_reset/Run()
	var/mob/living/carbon/human/consistent/tider = allocate(__IMPLIED_TYPE__)
	tider.set_stamina_loss(10)
	RegisterSignal(tider, COMSIG_LIVING_STAMINA_RESET, PROC_REF(reset_count))

	tider.adjust_stamina_loss(10)
	TEST_ASSERT_EQUAL(reset_count, 1, "Stamina timer reset should have been triggered (normal amount of damage)")
	tider.adjust_stamina_loss(INFINITY)
	TEST_ASSERT_EQUAL(reset_count, 2, "Stamina timer reset should have been triggered (entering stamcrit / hitting stamina damage cap)")
	tider.adjust_stamina_loss(10)
	TEST_ASSERT_EQUAL(reset_count, 3, "Stamina timer reset should have been triggered (regardless of being at the stamina damage cap)")
	tider.adjust_stamina_loss(0)
	TEST_ASSERT_EQUAL(reset_count, 4, "Stamina timer reset should have been triggered (even for 0 damage)")

	var/datum/status_effect/incapacitating/stamcrit/stamcrit_effect = tider.has_status_effect(/datum/status_effect/incapacitating/stamcrit)
	stamcrit_effect.diminishing_return_counter += INFINITY
	tider.adjust_stamina_loss(10)
	TEST_ASSERT_EQUAL(reset_count, 4, "Stamina timer reset should not have been triggered after stamcrit diminishing returns are applied")

/datum/unit_test/stam_reset/proc/reset_count()
	SIGNAL_HANDLER
	reset_count++
