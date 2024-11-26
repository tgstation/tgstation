/// Tests that sutures apply healing.
/datum/unit_test/use_sutures
	priority = TEST_LONGER

/datum/unit_test/use_sutures/Run()
	var/mob/living/carbon/human/consistent/healer = EASY_ALLOCATE()
	var/mob/living/carbon/human/consistent/victim = EASY_ALLOCATE()
	var/obj/item/stack/medical/suture/suture

	suture = get_suture()
	healer.put_in_active_hand(suture, forced = TRUE)
	victim.apply_damage(suture.heal_brute, BRUTE, BODY_ZONE_CHEST, wound_bonus = CANT_WOUND)
	click_wrapper(healer, victim)
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), 0, "Failed heal a mob with sutures while not on combat mode.")
	TEST_ASSERT(QDELETED(suture), "Suture was not consumed on use.")

	suture = get_suture()
	healer.put_in_active_hand(suture, forced = TRUE)
	healer.set_combat_mode(TRUE)
	victim.apply_damage(suture.heal_brute, BRUTE, BODY_ZONE_CHEST, wound_bonus = CANT_WOUND)
	click_wrapper(healer, victim)
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), 0, "Failed heal a mob with sutures while on combat mode.")

	suture = get_suture()
	healer.put_in_active_hand(suture, forced = TRUE)
	click_wrapper(healer, victim)
	TEST_ASSERT(!QDELETED(suture), "Suture was consumed on use even though no damage was healed.")

/datum/unit_test/use_sutures/proc/get_suture()
	var/obj/item/stack/medical/suture/suture = EASY_ALLOCATE(1)
	suture.other_delay = 0.2 SECONDS
	suture.assessing_injury_delay = 0 SECONDS
	return suture
