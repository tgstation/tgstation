#define TESTING_DAMAGE_TOXIN (1 << 0)
#define TESTING_DAMAGE_CLONE (1 << 1)
#define TESTING_DAMAGE_BRUTE (1 << 2)
#define TESTING_DAMAGE_BURN (1 << 3)
#define TESTING_DAMAGE_OXYLOSS (1 << 4)
#define TESTING_DAMAGE_STAMINA (1 << 5)

/datum/unit_test/mob_damage
	priority = TEST_LONGER

/datum/unit_test/mob_damage/Destroy()
	SSmobs.ignite()
	return ..()

/datum/unit_test/mob_damage/Run()
	SSmobs.pause()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	var/damage_returned

	/* The sanity tests: here we make sure that:
	 1) That damage procs are returning the expected values. They should be returning the amount of damage healed.
	    Negative values mean damage was taken, positive mean healing)
	 2) That the damage is being applied correctly to the mob. */

	test_sanity_simple(dummy)
	test_sanity_complex(dummy)

	// Testing if biotypes are working as intended
	test_biotypes(dummy)

	// Testing whether or not TRAIT_NOBREATH is working as intended
	test_nobreath(dummy)

	// Testing the proc ordered_healing()
	test_ordered_healing(dummy)

/datum/unit_test/mob_damage/proc/verify_damage(mob/living/testing_mob, amount, included_types = ALL)
	if(included_types & TESTING_DAMAGE_TOXIN)
		TEST_ASSERT_EQUAL(testing_mob.getToxLoss(), amount, \
			"[testing_mob] should have [amount] toxin damage, instead they have [testing_mob.getToxLoss()]!")
	if(included_types & TESTING_DAMAGE_CLONE)
		TEST_ASSERT_EQUAL(testing_mob.getCloneLoss(), amount, \
			"[testing_mob] should have [amount] clone damage, instead they have [testing_mob.getCloneLoss()]!")
	if(included_types & TESTING_DAMAGE_BRUTE)
		TEST_ASSERT_EQUAL(round(testing_mob.getBruteLoss(), 1), amount, \
			"[testing_mob] should have [amount] brute damage, instead they have [testing_mob.getBruteLoss()]!")
	if(included_types & TESTING_DAMAGE_BURN)
		TEST_ASSERT_EQUAL(round(testing_mob.getFireLoss(), 1), amount, \
			"[testing_mob] should have [amount] burn damage, instead they have [testing_mob.getFireLoss()]!")
	if(included_types & TESTING_DAMAGE_OXYLOSS)
		TEST_ASSERT_EQUAL(testing_mob.getOxyLoss(), amount, \
			"[testing_mob] should have [amount] oxy damage, instead they have [testing_mob.getOxyLoss()]!")
	if(included_types & TESTING_DAMAGE_STAMINA)
		TEST_ASSERT_EQUAL(testing_mob.getStaminaLoss(), amount, \
			"[testing_mob] should have [amount] stamina damage, instead they have [testing_mob.getStaminaLoss()]!")

/datum/unit_test/mob_damage/proc/apply_damage(mob/living/testing_mob, amount, expected = -amount, included_types = ALL, biotypes = ALL, bodytypes = ALL, forced = FALSE)
	var/damage_returned
	if(included_types & TESTING_DAMAGE_TOXIN)
		damage_returned = testing_mob.adjustToxLoss(amount, updating_health = FALSE, forced = forced, required_biotype = biotypes)
		TEST_ASSERT_EQUAL(damage_returned, expected, \
			"adjustToxLoss() should have returned [expected], but returned [damage_returned] instead!")
	if(included_types & TESTING_DAMAGE_CLONE)
		damage_returned = testing_mob.adjustCloneLoss(amount, updating_health = FALSE, forced = forced, required_biotype = biotypes)
		TEST_ASSERT_EQUAL(damage_returned, expected, \
			"adjustCloneLoss() should have returned [expected], but returned [damage_returned] instead!")
	if(included_types & TESTING_DAMAGE_BRUTE)
		damage_returned = round(testing_mob.adjustBruteLoss(amount, updating_health = FALSE, forced = forced), 1)
		TEST_ASSERT_EQUAL(damage_returned, expected, \
			"adjustBruteLoss() should have returned [expected], but returned [damage_returned] instead!")
	if(included_types & TESTING_DAMAGE_BURN)
		damage_returned = round(testing_mob.adjustFireLoss(amount, updating_health = FALSE, forced = forced), 1)
		TEST_ASSERT_EQUAL(damage_returned, expected, \
			"adjustFireLoss() should have returned [expected], but returned [damage_returned] instead!")
	if(included_types & TESTING_DAMAGE_OXYLOSS)
		damage_returned = testing_mob.adjustOxyLoss(amount, updating_health = FALSE, forced = forced, required_biotype = biotypes)
		TEST_ASSERT_EQUAL(damage_returned, expected, \
			"adjustOxyLoss() should have returned [expected], but returned [damage_returned] instead!")
	if(included_types & TESTING_DAMAGE_STAMINA)
		damage_returned = testing_mob.adjustStaminaLoss(amount, updating_stamina = FALSE, forced = forced, required_biotype = biotypes)
		TEST_ASSERT_EQUAL(damage_returned, expected, \
			"adjustStaminaLoss() should have returned [expected], but returned [damage_returned] instead!")

///	Sanity tests damage and healing using adjustToxLoss, adjustBruteLoss, etc
/datum/unit_test/mob_damage/proc/test_sanity_simple(mob/living/carbon/human/consistent/dummy)

	// Apply 5 damage and then heal it

	apply_damage(dummy, 5)
	verify_damage(dummy, 5)

	apply_damage(dummy, -5)
	verify_damage(dummy, 0)

	// More complicated healing
	// Apply 15 damage and heal 3

	apply_damage(dummy, 15)
	verify_damage(dummy, 15)

	apply_damage(dummy, -3)
	verify_damage(dummy, 12)

	// Now overheal by 666. It should heal for 12.

	apply_damage(dummy, -666, expected = 12)
	verify_damage(dummy, 0)

///	Sanity tests damage and healing using the more complex procs like take_overall_damage(), heal_overall_damage(), etc
/datum/unit_test/mob_damage/proc/test_sanity_complex(mob/living/carbon/human/consistent/dummy)
	var/damage_returned
	// take 5 brute, 2 burn
	damage_returned = round(dummy.take_bodypart_damage(5, 2, updating_health = FALSE), 1)
	TEST_ASSERT_EQUAL(damage_returned, -7, \
		"take_bodypart_damage() should have returned -7, but returned [damage_returned] instead!")

	TEST_ASSERT_EQUAL(round(dummy.getBruteLoss(), 1), 5, \
		"Dummy should have 5 brute damage, instead they have [dummy.getBruteLoss()]!")
	TEST_ASSERT_EQUAL(round(dummy.getFireLoss(), 1), 2, \
		"Dummy should have 2 burn damage, instead they have [dummy.getFireLoss()]!")

	// heal 4 brute, 1 burn
	damage_returned = round(dummy.heal_bodypart_damage(4, 1, updating_health = FALSE), 1)
	TEST_ASSERT_EQUAL(damage_returned, 5, \
		"heal_bodypart_damage() should have returned 5, but returned [damage_returned] instead!")

	verify_damage(dummy, 1, included_types = TESTING_DAMAGE_BRUTE|TESTING_DAMAGE_BURN)

	// heal 1 brute, 1 burn
	damage_returned = round(dummy.heal_overall_damage(1, 1, updating_health = FALSE), 1)
	TEST_ASSERT_EQUAL(damage_returned, 2, \
		"heal_overall_damage() should have returned 2, but returned [damage_returned] instead!")

	verify_damage(dummy, 0, included_types = TESTING_DAMAGE_BRUTE|TESTING_DAMAGE_BURN)

	// take 50 brute, 50 burn
	damage_returned = round(dummy.take_overall_damage(50, 50, updating_health = FALSE), 1)
	TEST_ASSERT_EQUAL(damage_returned, -100, \
		"take_overall_damage() should have returned -100, but returned [damage_returned] instead!")

	verify_damage(dummy, 50, included_types = TESTING_DAMAGE_BRUTE|TESTING_DAMAGE_BURN)

	// testing negative args with the overall damage procs

	damage_returned = round(dummy.take_bodypart_damage(-50, -50, updating_health = FALSE), 1)
	TEST_ASSERT_EQUAL(damage_returned, 0, \
		"take_bodypart_damage() should have returned 0, but returned [damage_returned] instead!")

	damage_returned = round(dummy.heal_bodypart_damage(-50, -50, updating_health = FALSE), 1)
	TEST_ASSERT_EQUAL(damage_returned, 0, \
		"heal_bodypart_damage() should have returned 0, but returned [damage_returned] instead!")

	damage_returned = round(dummy.take_overall_damage(-50, -50, updating_health = FALSE), 1)
	TEST_ASSERT_EQUAL(damage_returned, 0, \
		"take_overall_damage() should have returned 0, but returned [damage_returned] instead!")

	damage_returned = round(dummy.heal_overall_damage(-50, -50, updating_health = FALSE), 1)
	TEST_ASSERT_EQUAL(damage_returned, 0, \
		"heal_overall_damage() should have returned 0, but returned [damage_returned] instead!")

	verify_damage(dummy, 50, included_types = TESTING_DAMAGE_BRUTE|TESTING_DAMAGE_BURN)

	// testing overhealing

	damage_returned = round(dummy.heal_overall_damage(75, 99, updating_health = FALSE), 1)
	TEST_ASSERT_EQUAL(damage_returned, 100, \
		"heal_overall_damage() should have returned 100, but returned [damage_returned] instead!")

	verify_damage(dummy, 0, included_types = TESTING_DAMAGE_BRUTE|TESTING_DAMAGE_BURN)

/// Testing biotypes
/datum/unit_test/mob_damage/proc/test_biotypes(mob/living/carbon/human/consistent/dummy)
	// Testing biotypes using a plasmaman, who is MOB_MINERAL and MOB_HUMANOID
	dummy.set_species(/datum/species/plasmaman)

	// argumentless default: should default to required_biotype = ALL. The damage should be applied in that case.
	apply_damage(dummy, 1, included_types = TESTING_DAMAGE_TOXIN|TESTING_DAMAGE_CLONE|TESTING_DAMAGE_STAMINA)
	verify_damage(dummy, 1, included_types = TESTING_DAMAGE_TOXIN|TESTING_DAMAGE_CLONE|TESTING_DAMAGE_STAMINA)

	// If we specify MOB_ORGANIC, the damage should not get applied because plasmamen lack that biotype.
	apply_damage(dummy, 1, expected = 0, included_types = TESTING_DAMAGE_TOXIN|TESTING_DAMAGE_CLONE|TESTING_DAMAGE_STAMINA, biotypes = MOB_ORGANIC)
	verify_damage(dummy, 1, included_types = TESTING_DAMAGE_TOXIN|TESTING_DAMAGE_CLONE|TESTING_DAMAGE_STAMINA)

	// Now if we specify MOB_MINERAL the damage should get applied.
	apply_damage(dummy, 1, included_types = TESTING_DAMAGE_TOXIN|TESTING_DAMAGE_CLONE|TESTING_DAMAGE_STAMINA, biotypes = MOB_MINERAL)
	verify_damage(dummy, 2, included_types = TESTING_DAMAGE_TOXIN|TESTING_DAMAGE_CLONE|TESTING_DAMAGE_STAMINA)

	// Transform back to human
	dummy.set_species(/datum/species/human)

	// We have 2 damage presently.
	// Try to heal it; let's specify MOB_MINERAL, which should no longer work because we have changed back to a human.
	apply_damage(dummy, -2, expected = 0, included_types = TESTING_DAMAGE_TOXIN|TESTING_DAMAGE_CLONE|TESTING_DAMAGE_STAMINA, biotypes = MOB_MINERAL)
	verify_damage(dummy, 2, included_types = TESTING_DAMAGE_TOXIN|TESTING_DAMAGE_CLONE|TESTING_DAMAGE_STAMINA)

	// Force heal some of the damage. When forced = TRUE the damage/healing gets applied no matter what.
	apply_damage(dummy, -1, included_types = TESTING_DAMAGE_TOXIN|TESTING_DAMAGE_CLONE|TESTING_DAMAGE_STAMINA, biotypes = MOB_MINERAL, forced = TRUE)
	verify_damage(dummy, 1, included_types = TESTING_DAMAGE_TOXIN|TESTING_DAMAGE_CLONE|TESTING_DAMAGE_STAMINA)

	// Now heal the rest of it with the correct biotype. Make sure that this works. We should have 0 damage afterwards.
	apply_damage(dummy, -1, included_types = TESTING_DAMAGE_TOXIN|TESTING_DAMAGE_CLONE|TESTING_DAMAGE_STAMINA, biotypes = MOB_ORGANIC)
	verify_damage(dummy, 0, included_types = TESTING_DAMAGE_TOXIN|TESTING_DAMAGE_CLONE|TESTING_DAMAGE_STAMINA)

/// Testing oxyloss with the TRAIT_NOBREATH
/datum/unit_test/mob_damage/proc/test_nobreath(mob/living/carbon/human/consistent/dummy)
	// TRAIT_NOBREATH is supposed to prevent oxyloss damage (but not healing). Let's make sure that's the case.
	ADD_TRAIT(dummy, TRAIT_NOBREATH, TRAIT_SOURCE_UNIT_TESTS)
	// force some oxyloss here
	dummy.setOxyLoss(2, updating_health = FALSE, forced = TRUE)

	// Try to take more oxyloss damage with TRAIT_NOBREATH. It should not work.
	apply_damage(dummy, 2, expected = 0, included_types = TESTING_DAMAGE_OXYLOSS)
	verify_damage(dummy, 2, included_types = TESTING_DAMAGE_OXYLOSS)

	// Make sure we are still be able to heal the oxyloss. This should work.
	apply_damage(dummy, -2, included_types = TESTING_DAMAGE_OXYLOSS)
	verify_damage(dummy, 0, included_types = TESTING_DAMAGE_OXYLOSS)

	REMOVE_TRAIT(dummy, TRAIT_NOBREATH, TRAIT_SOURCE_UNIT_TESTS)

/// Testing heal_ordered_damage()
/datum/unit_test/mob_damage/proc/test_ordered_healing(mob/living/carbon/human/consistent/dummy)
	var/damage_returned

	// We apply 20 brute, 20 burn, and 20 toxin damage. 60 damage total
	apply_damage(dummy, 20, included_types = TESTING_DAMAGE_TOXIN|TESTING_DAMAGE_BRUTE|TESTING_DAMAGE_BURN)

	// Heal 30 damage of that, starting from brute
	damage_returned = round(dummy.heal_ordered_damage(30, list(BRUTE, BURN, TOX)), 1)
	TEST_ASSERT_EQUAL(damage_returned, 30, \
		"heal_ordered_damage() should have returned 30, but returned [damage_returned] instead!")

	// Should have 10 burn damage and 20 toxins damage remaining, let's check
	TEST_ASSERT_EQUAL(dummy.getBruteLoss(), 0, \
		"[src] should have 0 brute damage, but has [dummy.getBruteLoss()] instead!")
	TEST_ASSERT_EQUAL(dummy.getFireLoss(), 10, \
		"[src] should have 10 burn damage, but has [dummy.getFireLoss()] instead!")
	TEST_ASSERT_EQUAL(dummy.getToxLoss(), 20, \
		"[src] should have 2 toxin damage, but has [dummy.getToxLoss()] instead!")

	// Now heal the remaining 30, overhealing by 5.
	damage_returned = round(dummy.heal_ordered_damage(35, list(BRUTE, BURN, TOX)), 1)
	TEST_ASSERT_EQUAL(damage_returned, 30, \
		"heal_ordered_damage() should have returned 0, but returned [damage_returned] instead!")

	// Should have no damage remaining
	TEST_ASSERT_EQUAL(dummy.getBruteLoss(), 0, \
		"[src] should have 0 brute damage, but has [dummy.getBruteLoss()] instead!")
	TEST_ASSERT_EQUAL(dummy.getFireLoss(), 0, \
		"[src] should have 0 burn damage, but has [dummy.getFireLoss()] instead!")
	TEST_ASSERT_EQUAL(dummy.getToxLoss(), 0, \
		"[src] should have 0 toxin damage, but has [dummy.getToxLoss()] instead!")

/// Tests that mob damage procs are working as intended for basic mobs
/datum/unit_test/mob_damage/basic

/datum/unit_test/mob_damage/basic/Run()
	SSmobs.pause()
	var/mob/living/basic/mouse/gray/gusgus = allocate(/mob/living/basic/mouse/gray)
	// give gusgus a damage_coeff of 1 for this test
	gusgus.damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 1, OXY = 1)
	// tank mouse
	gusgus.maxHealth = 200

	test_sanity_simple(gusgus)
	test_sanity_complex(gusgus)

/datum/unit_test/mob_damage/basic/verify_damage(mob/living/testing_mob, amount, expected, included_types = ALL)
	if(included_types & TESTING_DAMAGE_TOXIN)
		TEST_ASSERT_EQUAL(testing_mob.getToxLoss(), 0, \
			"[testing_mob] should have [0] toxin damage, instead they have [testing_mob.getToxLoss()]!")
	if(included_types & TESTING_DAMAGE_CLONE)
		TEST_ASSERT_EQUAL(testing_mob.getCloneLoss(), 0, \
			"[testing_mob] should have [0] clone damage, instead they have [testing_mob.getCloneLoss()]!")
	if(included_types & TESTING_DAMAGE_BRUTE)
		TEST_ASSERT_EQUAL(round(testing_mob.getBruteLoss(), 1), expected || amount * 5, \
			"[testing_mob] should have [expected || amount * 5] brute damage, instead they have [testing_mob.getBruteLoss()]!")
	if(included_types & TESTING_DAMAGE_BURN)
		TEST_ASSERT_EQUAL(round(testing_mob.getFireLoss(), 1), 0, \
			"[testing_mob] should have [0] burn damage, instead they have [testing_mob.getFireLoss()]!")
	if(included_types & TESTING_DAMAGE_OXYLOSS)
		TEST_ASSERT_EQUAL(testing_mob.getOxyLoss(), 0, \
			"[testing_mob] should have [0] oxy damage, instead they have [testing_mob.getOxyLoss()]!")
	if(included_types & TESTING_DAMAGE_STAMINA)
		TEST_ASSERT_EQUAL(testing_mob.getStaminaLoss(), amount, \
			"[testing_mob] should have [amount] stamina damage, instead they have [testing_mob.getStaminaLoss()]!")

/datum/unit_test/mob_damage/basic/test_sanity_simple(mob/living/basic/mouse/gray/gusgus)
	var/damage_returned

	// check to see if basic mob damage works

	// Simple damage and healing
	// Take 1 damage, heal for 1

	apply_damage(gusgus, 1)
	verify_damage(gusgus, 1)

	apply_damage(gusgus, -1)
	verify_damage(gusgus, 0)

	// More complicated healing

	apply_damage(gusgus, 2)
	verify_damage(gusgus, 2)

	// underhealing

	apply_damage(gusgus, -1)
	verify_damage(gusgus, 1)

	// overhealing

	damage_returned = gusgus.adjustToxLoss(-11, updating_health = FALSE)
	TEST_ASSERT_EQUAL(damage_returned, 5, \
		"adjustToxLoss() should have returned 1, but returned [damage_returned] instead!")
	damage_returned = gusgus.adjustCloneLoss(-35, updating_health = FALSE)
	TEST_ASSERT_EQUAL(damage_returned, 0, \
		"adjustCloneLoss() should have returned 0, but returned [damage_returned] instead!")
	damage_returned = gusgus.adjustBruteLoss(-65, updating_health = FALSE)
	TEST_ASSERT_EQUAL(damage_returned, 0, \
		"adjustBruteLoss() should have returned 0, but returned [damage_returned] instead!")
	damage_returned = gusgus.adjustFireLoss(-75, updating_health = FALSE)
	TEST_ASSERT_EQUAL(damage_returned, 0, \
		"adjustFireLoss() should have returned 0, but returned [damage_returned] instead!")
	damage_returned = gusgus.adjustOxyLoss(-123, updating_health = FALSE)
	TEST_ASSERT_EQUAL(damage_returned, 0, \
		"adjustOxyLoss() should have returned 0, but returned [damage_returned] instead!")
	damage_returned = gusgus.adjustStaminaLoss(-666, updating_stamina = FALSE)
	TEST_ASSERT_EQUAL(damage_returned, 1, \
		"adjustStaminaLoss() should have returned 1, but returned [damage_returned] instead!")

	verify_damage(gusgus, 0)

/datum/unit_test/mob_damage/basic/test_sanity_complex(mob/living/basic/mouse/gray/gusgus)
	var/damage_returned
	// overall damage procs

	// take 5 brute, 2 burn
	damage_returned = gusgus.take_bodypart_damage(5, 2, updating_health = FALSE)
	TEST_ASSERT_EQUAL(damage_returned, -7, \
		"take_bodypart_damage() should have returned -7, but returned [damage_returned] instead!")

	TEST_ASSERT_EQUAL(gusgus.bruteloss, 7, \
		"Mouse should have 7 brute damage, instead they have [gusgus.bruteloss]!")
	TEST_ASSERT_EQUAL(gusgus.fireloss, 0, \
		"Mouse should have 0 burn damage, instead they have [gusgus.fireloss]!")

	// heal 4 brute, 1 burn
	damage_returned = gusgus.heal_bodypart_damage(4, 1, updating_health = FALSE)
	TEST_ASSERT_EQUAL(damage_returned, 5, \
		"heal_bodypart_damage() should have returned 5, but returned [damage_returned] instead!")

	TEST_ASSERT_EQUAL(gusgus.bruteloss, 2, \
		"Mouse should have 2 brute damage, instead they have [gusgus.bruteloss]!")
	TEST_ASSERT_EQUAL(gusgus.fireloss, 0, \
		"Mouse should have 0 burn damage, instead they have [gusgus.fireloss]!")

	// heal 1 brute, 1 burn
	damage_returned = gusgus.heal_overall_damage(1, 1, updating_health = FALSE)
	TEST_ASSERT_EQUAL(damage_returned, 2, \
		"heal_overall_damage() should have returned 2, but returned [damage_returned] instead!")

	TEST_ASSERT_EQUAL(gusgus.bruteloss, 0, \
		"Mouse should have 0 brute damage, instead they have [gusgus.bruteloss]!")
	TEST_ASSERT_EQUAL(gusgus.fireloss, 0, \
		"Mouse should have 0 burn damage, instead they have [gusgus.fireloss]!")

	// take 50 brute, 50 burn
	damage_returned = gusgus.take_overall_damage(3, 3, updating_health = FALSE)
	TEST_ASSERT_EQUAL(damage_returned, -6, \
		"take_overall_damage() should have returned -6, but returned [damage_returned] instead!")

	verify_damage(gusgus, 1, expected = 6, included_types = TESTING_DAMAGE_BRUTE)

	// testing negative args with the overall damage procs

	damage_returned = gusgus.take_bodypart_damage(-50, -50, updating_health = FALSE)
	TEST_ASSERT_EQUAL(damage_returned, 0, \
		"take_bodypart_damage() should have returned 0, but returned [damage_returned] instead!")

	damage_returned = gusgus.heal_bodypart_damage(-50, -50, updating_health = FALSE)
	TEST_ASSERT_EQUAL(damage_returned, 0, \
		"heal_bodypart_damage() should have returned 0, but returned [damage_returned] instead!")

	damage_returned = gusgus.take_overall_damage(-50, -50, updating_health = FALSE)
	TEST_ASSERT_EQUAL(damage_returned, 0, \
		"take_overall_damage() should have returned 0, but returned [damage_returned] instead!")

	damage_returned = gusgus.heal_overall_damage(-50, -50, updating_health = FALSE)
	TEST_ASSERT_EQUAL(damage_returned, 0, \
		"heal_overall_damage() should have returned 0, but returned [damage_returned] instead!")

	verify_damage(gusgus, 1, expected = 6, included_types = TESTING_DAMAGE_BRUTE)

	// testing overhealing

	damage_returned = gusgus.heal_overall_damage(75, 99, updating_health = FALSE)
	TEST_ASSERT_EQUAL(damage_returned, 6, \
		"heal_overall_damage() should have returned 6, but returned [damage_returned] instead!")

	verify_damage(gusgus, 0, included_types = TESTING_DAMAGE_BRUTE)

#undef TESTING_DAMAGE_TOXIN
#undef TESTING_DAMAGE_CLONE
#undef TESTING_DAMAGE_BRUTE
#undef TESTING_DAMAGE_BURN
#undef TESTING_DAMAGE_OXYLOSS
#undef TESTING_DAMAGE_STAMINA
