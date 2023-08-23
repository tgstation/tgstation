/// Abstract test type for use in easily testing blocking setups.
/datum/unit_test/blocking
	abstract_type = /datum/unit_test/blocking

/datum/unit_test/blocking/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)

	setup_attacker(attacker)
	setup_victim(victim)

	click_wrapper(attacker, victim)

	test_results(attacker, victim)

/datum/unit_test/blocking/proc/setup_attacker(mob/living/carbon/human/attacker)
	attacker.set_combat_mode(TRUE)

/datum/unit_test/blocking/proc/setup_victim(mob/living/carbon/human/victim)
	victim.begin_blocking()

/datum/unit_test/blocking/proc/test_results(mob/living/carbon/human/attacker, mob/living/carbon/human/victim)
	return

/// Tests bare handed blocking
/datum/unit_test/blocking/bare_handed

/datum/unit_test/blocking/bare_handed/test_results(mob/living/carbon/human/attacker, mob/living/carbon/human/victim)
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), 0, "Victim took brute damage despite blocking bare handed.")
	TEST_ASSERT_NOTEQUAL(victim.getStaminaLoss(), 0, "Victim failed to take any stamina from blocking bare handed.")

/// Tests blocking while holding an item / shield
/datum/unit_test/blocking/shield

/datum/unit_test/blocking/shield/setup_victim(mob/living/carbon/human/victim)
	var/obj/item/shield/riot/shield = allocate(/obj/item/shield/riot)
	victim.put_in_inactive_hand(shield, forced = TRUE)
	return ..()

/datum/unit_test/blocking/shield/test_results(mob/living/carbon/human/attacker, mob/living/carbon/human/victim)
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), 0, "Victim took brute damage despite blocking with a shield.")
	TEST_ASSERT_NOTEQUAL(victim.getStaminaLoss(), 0, "Victim failed to take any stamina from blocking with a shield.")

/// Tests blocking while holding an item / shield against someone wielding a weapon rather than barehanded
/datum/unit_test/blocking/shield/with_weapon

/datum/unit_test/blocking/shield/with_weapon/setup_attacker(mob/living/carbon/human/attacker)
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)
	attacker.put_in_active_hand(toolbox, forced = TRUE)
	return ..()

/datum/unit_test/blocking/shield/with_weapon/test_results(mob/living/carbon/human/attacker, mob/living/carbon/human/victim)
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), 0, "Victim took brute damage despite blocking with a shield against an attacker with a toolbox.")
	TEST_ASSERT_NOTEQUAL(victim.getStaminaLoss(), 0, "Victim failed to take any stamina from blocking with a shield against an attacker with a toolbox..")

/// Test blocking against something which has full armor penetration, which should ignore block
/datum/unit_test/blocking/unblockable

/datum/unit_test/blocking/unblockable/setup_attacker(mob/living/carbon/human/attacker)
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)
	toolbox.armour_penetration = 100
	attacker.put_in_active_hand(toolbox, forced = TRUE)
	return ..()

/datum/unit_test/blocking/unblockable/test_results(mob/living/carbon/human/attacker, mob/living/carbon/human/victim)
	TEST_ASSERT_NOTEQUAL(victim.getBruteLoss(), 0, "Victim failed to take brute damage from an item that penetrates block.")

/// Test blocking touch spells, with should ignore block
/datum/unit_test/blocking/touch_spells

/datum/unit_test/blocking/touch_spells/setup_attacker(mob/living/carbon/human/attacker)
	var/datum/action/cooldown/spell/touch/mansus_grasp/grasp = new(attacker)
	grasp.Grant(attacker)
	grasp.Trigger()
	if(!istype(attacker.get_active_held_item(), grasp.hand_path))
		TEST_FAIL("Mansus grasp failed to place a touch attack item in the attacker's hand, a prerequisite for this test.")

	return ..()

/datum/unit_test/blocking/touch_spells/test_results(mob/living/carbon/human/attacker, mob/living/carbon/human/victim)
	TEST_ASSERT_NOTEQUAL(victim.getBruteLoss() + victim.getFireLoss(), 0, "Victim failed to take damage from Mansus Grasp against a blocking foe, which should penetrate block.")

// Tests the [TRAIT_CANNOT_HEAL_STAMINA] trait blocking uses
/datum/unit_test/no_stam_healing

/datum/unit_test/no_stam_healing/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)

	ADD_TRAIT(victim, TRAIT_CANNOT_HEAL_STAMINA, TRAIT_SOURCE_UNIT_TESTS)
	victim.adjustStaminaLoss(10)
	TEST_ASSERT_EQUAL(victim.getStaminaLoss(), 10, "Victim did not take stamina damage while blocking.")

	victim.adjustStaminaLoss(-10)
	TEST_ASSERT_EQUAL(victim.getStaminaLoss(), 10, "Victim healed stamina damage while blocking.")
