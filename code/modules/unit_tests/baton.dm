/// Tests a variety of baton interactions with a variety of baton types
/datum/unit_test/baton
	abstract_type = /datum/unit_test/baton
	/// Baton type being tested
	var/obj/item/melee/baton/baton_type
	/// Description of the click type being tested
	var/click_descriptor
	/// Modifiers for the click being tested
	var/list/click_modifiers
	/// Whether the attacker is in combat mode
	var/combat_mode = TRUE
	/// Whether the baton is active
	var/use_baton = TRUE

/datum/unit_test/baton/Run()
	var/mob/living/carbon/human/consistent/secoff = EASY_ALLOCATE()
	var/mob/living/carbon/human/consistent/tider = EASY_ALLOCATE()
	ADD_TRAIT(secoff, TRAIT_PERFECT_ATTACKER, TRAIT_SOURCE_UNIT_TESTS)

	var/obj/item/melee/baton/stun_baton = allocate(baton_type)
	secoff.put_in_active_hand(stun_baton)
	secoff.set_combat_mode(combat_mode)
	if(use_baton)
		stun_baton.attack_self(secoff)

	test_attack(secoff, tider)

/// Performs two attacks, tests the resulting damage on the defender
/datum/unit_test/baton/proc/test_attack(mob/living/attacker, mob/living/defender, obj/item/melee/baton/baton)
	// Perform an attack, while off baton cooldown
	click_wrapper(attacker, defender, click_modifiers)
	TEST_ASSERT_EQUAL(defender.get_stamina_loss(), asserted_stamina_damage(), \
		"[baton_type::name] did an incorrect amount of stamina damage to target ([get_descriptor()])")
	TEST_ASSERT_EQUAL(defender.get_brute_loss(), asserted_brute_damage(), \
		"[baton_type::name] did an incorrect amount of brute damage to target ([get_descriptor()])")

	// Now perform an attack while on baton cooldown
	click_wrapper(attacker, defender, click_modifiers)
	TEST_ASSERT_EQUAL(defender.get_stamina_loss(), asserted_stamina_damage(), \
		"[baton_type::name] did an incorrect amount of stamina damage to target while on cooldown ([get_descriptor()])")
	TEST_ASSERT_EQUAL(defender.get_brute_loss(), asserted_brute_damage() * 2, \
		"[baton_type::name] did an incorrect amount of brute damage to target while on cooldown ([get_descriptor()])")

/// How much stamina damage is expected from this test case
/datum/unit_test/baton/proc/asserted_stamina_damage()
	return baton_type::stamina_damage

/// How much brute damage is expected from this test case
/datum/unit_test/baton/proc/asserted_brute_damage()
	return baton_type::force

/// Description of the current test case
/datum/unit_test/baton/proc/get_descriptor()
	return "[click_descriptor] \
		/ [combat_mode ? "in combat mode" : "not in combat mode"] \
		/ [use_baton ? "active baton" : "inactive baton"]"

/datum/unit_test/baton/left_click
	abstract_type = /datum/unit_test/baton/left_click
	click_descriptor = "left click"
	click_modifiers = list(LEFT_CLICK = TRUE, BUTTON = LEFT_CLICK)

/datum/unit_test/baton/right_click
	abstract_type = /datum/unit_test/baton/right_click
	click_descriptor = "right click"
	click_modifiers = list(RIGHT_CLICK = TRUE, BUTTON = RIGHT_CLICK)

// Left click sec baton
/datum/unit_test/baton/left_click/sec
	abstract_type = /datum/unit_test/baton/left_click/sec
	baton_type = /obj/item/melee/baton/security/loaded

// - Active + combat mode = stuns, no damage
/datum/unit_test/baton/left_click/sec/on_with_combat
	combat_mode = TRUE
	use_baton = TRUE

/datum/unit_test/baton/left_click/sec/on_with_combat/asserted_brute_damage()
	return 0

// - Active + no combat mode = stuns, no damage
/datum/unit_test/baton/left_click/sec/on_no_combat
	combat_mode = FALSE
	use_baton = TRUE

/datum/unit_test/baton/left_click/sec/on_no_combat/asserted_brute_damage()
	return 0

// - Inactive + combat mode = no stun, deals damage
/datum/unit_test/baton/left_click/sec/off_with_combat
	combat_mode = TRUE
	use_baton = FALSE

/datum/unit_test/baton/left_click/sec/off_with_combat/asserted_stamina_damage()
	return 0

// - Inactive + no combat mode = no sun, no damage
/datum/unit_test/baton/left_click/sec/off_no_combat
	combat_mode = FALSE
	use_baton = FALSE

/datum/unit_test/baton/left_click/sec/off_no_combat/asserted_stamina_damage()
	return 0

/datum/unit_test/baton/left_click/sec/off_no_combat/asserted_brute_damage()
	return 0

// Right click sec baton
/datum/unit_test/baton/right_click/sec
	baton_type = /obj/item/melee/baton/security/loaded

// - Active + combat mode = stuns, deals damage
/datum/unit_test/baton/right_click/sec/on_with_combat
	combat_mode = TRUE
	use_baton = TRUE

// - Active + no combat mode = stuns, deals damage
/datum/unit_test/baton/right_click/sec/on_no_combat
	combat_mode = FALSE
	use_baton = TRUE

// - Inactive + combat mode = no stun, deals damage
/datum/unit_test/baton/right_click/sec/attack_when_off
	use_baton = FALSE

/datum/unit_test/baton/right_click/sec/attack_when_off/asserted_stamina_damage()
	return 0

// - Inactive + no combat mode = no stun, deals damage
/datum/unit_test/baton/right_click/sec/attack_when_off/no_combat
	combat_mode = FALSE

/datum/unit_test/baton/right_click/sec/attack_when_off/no_combat/asserted_stamina_damage()
	return 0

// Left click stunprod
/datum/unit_test/baton/left_click/prod
	abstract_type = /datum/unit_test/baton/left_click/prod
	baton_type = /obj/item/melee/baton/security/cattleprod/loaded

// - Active + combat mode = stuns, no damage
/datum/unit_test/baton/left_click/prod/on_with_combat
	combat_mode = TRUE
	use_baton = TRUE

/datum/unit_test/baton/left_click/prod/on_with_combat/asserted_brute_damage()
	return 0

// - Active + no combat mode = stuns, no damage
/datum/unit_test/baton/left_click/prod/on_no_combat
	combat_mode = FALSE
	use_baton = TRUE

/datum/unit_test/baton/left_click/prod/on_no_combat/asserted_brute_damage()
	return 0

// - Inactive + combat mode = no stun, damages
/datum/unit_test/baton/left_click/prod/off_with_combat
	combat_mode = TRUE
	use_baton = FALSE

/datum/unit_test/baton/left_click/prod/off_with_combat/asserted_stamina_damage()
	return 0

// - Inactive + no combat mode = no stun, no damage
/datum/unit_test/baton/left_click/prod/off_no_combat
	combat_mode = FALSE
	use_baton = FALSE

/datum/unit_test/baton/left_click/prod/off_no_combat/asserted_stamina_damage()
	return 0

/datum/unit_test/baton/left_click/prod/off_no_combat/asserted_brute_damage()
	return 0

// Right click stunprod
/datum/unit_test/baton/right_click/prod
	abstract_type = /datum/unit_test/baton/right_click/prod
	baton_type = /obj/item/melee/baton/security/cattleprod/loaded

// - Active + combat mode = stuns, deals damage
/datum/unit_test/baton/right_click/prod/on_with_combat
	combat_mode = TRUE
	use_baton = TRUE

// - Active + no combat mode = stuns, deals damage
/datum/unit_test/baton/right_click/prod/on_no_combat
	combat_mode = FALSE
	use_baton = TRUE

// - Inactive + combat mode = no stun, deals damage
/datum/unit_test/baton/right_click/prod/attack_when_off
	combat_mode = TRUE
	use_baton = FALSE

/datum/unit_test/baton/right_click/prod/attack_when_off/asserted_stamina_damage()
	return 0

// - Inactive + no combat mode = no stun, deals damage
/datum/unit_test/baton/right_click/prod/attack_when_off/no_combat
	combat_mode = FALSE
	use_baton = FALSE

/datum/unit_test/baton/right_click/prod/attack_when_off/no_combat/asserted_stamina_damage()
	return 0

// Left click det baton
// - Always stuns never damages, regardless of combat mode
/datum/unit_test/baton/left_click/det
	baton_type = /obj/item/melee/baton
	use_baton = FALSE
	combat_mode = FALSE

/datum/unit_test/baton/left_click/det/asserted_brute_damage()
	return 0

/datum/unit_test/baton/left_click/det/combat_mode
	combat_mode = TRUE

// Right click det baton
// - Never stuns, always damages, regardless of combat mode (see: stun_on_harmbaton var)
/datum/unit_test/baton/right_click/det
	baton_type = /obj/item/melee/baton
	use_baton = FALSE

/datum/unit_test/baton/right_click/det/asserted_stamina_damage()
	return 0

/datum/unit_test/baton/right_click/det/combat_mode
	combat_mode = TRUE
