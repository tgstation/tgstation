/// Tests that sutures apply healing.
/datum/unit_test/use_sutures
	var/apply_verb = "not on combat mode"

/datum/unit_test/use_sutures/Run()
	var/mob/living/carbon/human/healer = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/stack/medical/suture/suture = allocate(/obj/item/stack/medical/suture)
	suture.other_delay = 0.2 SECONDS

	healer.put_in_active_hand(suture, forced = TRUE)
	ready_healer(healer)
	victim.apply_damage(suture.heal_brute, BRUTE, BODY_ZONE_CHEST)
	click_wrapper(healer, victim)
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), 0, "Failed heal a mob with sutures while [apply_verb].")

/datum/unit_test/use_sutures/proc/ready_healer(mob/living/carbon/human/healer)
	return

/// Tests that sutures apply healing while on combat mode.
/datum/unit_test/use_sutures/combat_mode
	apply_verb = "on combat mode"

/datum/unit_test/use_sutures/combat_mode/ready_healer(mob/living/carbon/human/healer)
	healer.set_combat_mode(TRUE)
