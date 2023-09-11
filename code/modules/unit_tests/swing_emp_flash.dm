/datum/unit_test/emp_flashlight
	var/sig_caught = 0

/datum/unit_test/emp_flashlight/Run()
	var/mob/living/carbon/human/flashlighter = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/flashlight/emp/debug/flashlight = allocate(/obj/item/flashlight/emp/debug)

	flashlighter.put_in_active_hand(flashlight, forced = TRUE)
	RegisterSignal(victim, COMSIG_ATOM_EMP_ACT, PROC_REF(sig_caught))

	click_wrapper(flashlighter, victim)
	TEST_ASSERT(sig_caught > 1, "EMP flashlight did not EMP the target on click")

/datum/unit_test/emp_flashlight/proc/sig_caught()
	SIGNAL_HANDLER
	sig_caught++
