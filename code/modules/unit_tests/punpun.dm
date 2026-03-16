/datum/unit_test/punpun_name

/datum/unit_test/punpun_name/Run()
	var/mob/living/carbon/human/species/monkey/punpun/punpun = EASY_ALLOCATE()
	TEST_ASSERT_EQUAL(punpun.name, initial(punpun.name), "Pun Pun did not have [punpun.p_their()] name set")
