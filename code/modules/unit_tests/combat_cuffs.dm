/// Tests that handcuffs can be applied.
/datum/unit_test/apply_cuffs

/datum/unit_test/apply_cuffs/Run()
	var/mob/living/carbon/human/consistent/attacker = EASY_ALLOCATE()
	var/mob/living/carbon/human/consistent/victim = EASY_ALLOCATE()
	var/obj/item/restraints/handcuffs/cuffs = EASY_ALLOCATE()
	cuffs.handcuff_time = 0.1 SECONDS
	attacker.put_in_active_hand(cuffs, forced = TRUE)
	click_wrapper(attacker, victim)
	TEST_ASSERT_EQUAL(victim.handcuffed, cuffs, "Handcuff attempt (non-combat-mode) failed in an otherwise valid setup.")

	victim.clear_cuffs(cuffs)
	attacker.put_in_active_hand(cuffs, forced = TRUE)
	attacker.set_combat_mode(TRUE)
	click_wrapper(attacker, victim)
	TEST_ASSERT_EQUAL(victim.handcuffed, cuffs, "Handcuff attempt (combat-mode) failed in an otherwise valid setup.")
