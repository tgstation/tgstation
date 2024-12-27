/// Test getting over a certain threshold of oxy damage results in KO
/datum/unit_test/oxyloss_suffocation

/datum/unit_test/oxyloss_suffocation/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)

	dummy.setOxyLoss(75)
	TEST_ASSERT(HAS_TRAIT_FROM(dummy, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT), "Dummy should have been knocked out from taking oxy damage.")
	dummy.setOxyLoss(0)
	TEST_ASSERT(!HAS_TRAIT_FROM(dummy, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT), "Dummy should have woken up from KO when healing to 0 oxy damage.")
