/datum/unit_test/baton
	abstract_type = /datum/unit_test/baton
	var/baton_type
	var/test_descriptor
	var/list/click_modifiers = list(LEFT_CLICK = TRUE, BUTTON = LEFT_CLICK)

/datum/unit_test/baton/Run()
	var/mob/living/carbon/human/consistent/secoff = EASY_ALLOCATE()
	var/mob/living/carbon/human/consistent/tider = EASY_ALLOCATE()
	ADD_TRAIT(secoff, TRAIT_PERFECT_ATTACKER, TRAIT_SOURCE_UNIT_TESTS)

	var/obj/item/melee/baton/stun_baton = allocate(baton_type)
	secoff.put_in_active_hand(stun_baton)
	stun_baton.attack_self(secoff)

	test_attack(secoff, tider)

/datum/unit_test/baton/proc/test_attack(mob/living/attacker, mob/living/defender, obj/item/melee/baton)
	// Test that we can stun a target
	click_wrapper(attacker, defender, click_modifiers)
	TEST_ASSERT(defender.get_stamina_loss() > 0, \
		"[baton_type] did no stamina damage to target ([test_descriptor])")

	click_wrapper(attacker, defender, click_modifiers)
	TEST_ASSERT(defender.get_stamina_loss() < 100, \
		"[baton_type] did stamina damage twice to target when it should be on cooldown ([test_descriptor])")

/datum/unit_test/baton/left_click
	abstract_type = /datum/unit_test/baton/left_click
	test_descriptor = "left click"

/datum/unit_test/baton/right_click
	abstract_type = /datum/unit_test/baton/right_click
	test_descriptor = "right click"

/datum/unit_test/baton/right_click/test_attack(mob/living/attacker, mob/living/defender, obj/item/melee/baton)
	. = ..()
	TEST_ASSERT(defender.get_brute_loss() == baton.force * 2, \
		"[baton_type] should have done brute damage on right click twice to target ([test_descriptor])")

/datum/unit_test/baton/left_click/sec
	baton_type = /obj/item/melee/baton/security/loaded

/datum/unit_test/baton/right_click/sec
	baton_type = /obj/item/melee/baton/security/loaded

/datum/unit_test/baton/left_click/prod
	baton_type = /obj/item/melee/baton/cattleprod/loaded

/datum/unit_test/baton/right_click/prod
	baton_type = /obj/item/melee/baton/cattleprod/loaded

/datum/unit_test/baton/left_click/det
	baton_type = /obj/item/melee/baton

/datum/unit_test/baton/right_click/det
	baton_type = /obj/item/melee/baton
