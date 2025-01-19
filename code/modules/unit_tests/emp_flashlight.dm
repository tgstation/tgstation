/// Test EMP flashlight EMPs people you point it at
/datum/unit_test/emp_flashlight
	var/sig_caught = 0

/datum/unit_test/emp_flashlight/Run()
	var/mob/living/carbon/human/consistent/flashlighter = EASY_ALLOCATE()
	var/mob/living/carbon/human/consistent/victim = EASY_ALLOCATE()
	var/obj/item/flashlight/emp/debug/flashlight = EASY_ALLOCATE()

	flashlighter.put_in_active_hand(flashlight, forced = TRUE)
	RegisterSignal(victim, COMSIG_ATOM_EMP_ACT, PROC_REF(sig_caught))

	click_wrapper(flashlighter, victim)
	TEST_ASSERT_NOTEQUAL(sig_caught, 0, "EMP flashlight did not EMP the target on click.")

/datum/unit_test/emp_flashlight/proc/sig_caught()
	SIGNAL_HANDLER
	sig_caught++
