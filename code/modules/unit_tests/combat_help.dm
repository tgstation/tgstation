/// Tests help intent clicking on people, particularly ensuring it results in a help_shake (check self or hug)
/datum/unit_test/help_click
	var/helper_times_helped = 0
	var/helpee_times_helped = 0

/datum/unit_test/help_click/Run()
	var/mob/living/carbon/human/consistent/helps_the_guy = EASY_ALLOCATE()
	var/mob/living/carbon/human/consistent/gets_the_help = EASY_ALLOCATE()

	gets_the_help.forceMove(locate(helps_the_guy.x + 1, helps_the_guy.y, helps_the_guy.z))

	RegisterSignal(helps_the_guy, COMSIG_CARBON_PRE_MISC_HELP, PROC_REF(helper_help_received))
	RegisterSignal(gets_the_help, COMSIG_CARBON_PRE_MISC_HELP, PROC_REF(helpee_help_received))

	// Click on self
	click_wrapper(helps_the_guy, helps_the_guy)

	TEST_ASSERT_EQUAL(helper_times_helped, 1, "Helper should have been helped once - clicking on themselves should check self.")
	TEST_ASSERT_EQUAL(helpee_times_helped, 0, "Helpee should not have been helped - helper clicked on themselves.")

	// Click on the other guy
	click_wrapper(helps_the_guy, gets_the_help)

	TEST_ASSERT_EQUAL(helper_times_helped, 1, "Helper should not have been helped - helper clicked on helpee.")
	TEST_ASSERT_EQUAL(helpee_times_helped, 1, "Helpee should have been helped once - helper clicked on helpee.")

/datum/unit_test/help_click/proc/helper_help_received()
	SIGNAL_HANDLER
	helper_times_helped += 1

/datum/unit_test/help_click/proc/helpee_help_received()
	SIGNAL_HANDLER
	helpee_times_helped += 1
