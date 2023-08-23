/// Tests that eyestabbing with combat mode on does damage to the eyes.
/datum/unit_test/eyestab

/datum/unit_test/eyestab/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/screwdriver/stabber = allocate(/obj/item/screwdriver)

	attacker.zone_selected = BODY_ZONE_PRECISE_EYES
	attacker.put_in_active_hand(stabber, forced = TRUE)

	click_wrapper(attacker, victim)
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), 0, "Victim should not have taken any brute damage from an eyestab with no combat mode")

	attacker.set_combat_mode(TRUE)
	click_wrapper(attacker, victim)
	TEST_ASSERT_NOTEQUAL(victim.getBruteLoss(), 0, "Victim should have taken some brute damage from an eyestab with combat mode on")

	var/obj/item/organ/internal/eyes/eyes = victim.get_organ_slot(ORGAN_SLOT_EYES)
	TEST_ASSERT_NOTEQUAL(eyes.damage, 0, "Victim's eyes should have taken some damage from an eyestab with combat mode on")
