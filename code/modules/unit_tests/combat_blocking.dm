/// Test that items can block unarmed attacks
/datum/unit_test/unarmed_blocking

/datum/unit_test/unarmed_blocking/Run()
	var/mob/living/carbon/human/consistent/attacker = EASY_ALLOCATE()
	var/mob/living/carbon/human/consistent/victim = EASY_ALLOCATE()
	var/obj/item/chair/chair = EASY_ALLOCATE()
	chair.hit_reaction_chance = 100
	victim.put_in_active_hand(chair, forced = TRUE)
	attacker.set_combat_mode(TRUE)
	ADD_TRAIT(attacker, TRAIT_PERFECT_ATTACKER, TRAIT_SOURCE_UNIT_TESTS)

	click_wrapper(attacker, victim)
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), 0, "Victim took damage from being punched despite having a 100% block chance chair in their hands.")

/// Test that items can block weapon attacks
/datum/unit_test/armed_blocking

/datum/unit_test/armed_blocking/Run()
	var/mob/living/carbon/human/consistent/attacker = EASY_ALLOCATE()
	var/mob/living/carbon/human/consistent/victim = EASY_ALLOCATE()
	var/obj/item/shield/riot/shield = EASY_ALLOCATE()
	shield.block_chance = INFINITY
	victim.put_in_active_hand(shield, forced = TRUE)
	attacker.set_combat_mode(TRUE)
	ADD_TRAIT(attacker, TRAIT_PERFECT_ATTACKER, TRAIT_SOURCE_UNIT_TESTS)

	click_wrapper(attacker, victim)
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), 0, "Victim took damage from being punched despite having a 100% block chance shield in their hands.")

	var/obj/item/storage/toolbox/weapon = EASY_ALLOCATE()
	attacker.put_in_active_hand(weapon, forced = TRUE)

	click_wrapper(attacker, victim)
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), 0, "Victim took damage from being hit with a weapon despite having a 100% block chance shield in their hands.")
