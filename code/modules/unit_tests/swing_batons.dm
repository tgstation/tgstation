/// Abstract test type used to setup a situation in which a baton is being used to swing on someone
/datum/unit_test/baton_swings
	abstract_type = /datum/unit_test/baton_swings

/datum/unit_test/baton_swings/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/melee/baton/baton = allocate(/obj/item/melee/baton/security/loaded)

	baton.attack_self(attacker)
	victim.forceMove(locate(attacker.x + 1, attacker.y, attacker.z))
	attacker.put_in_active_hand(baton, forced = TRUE)
	var/click_params = list2params(get_click_params())

	prepare_attacker(attacker)
	click_wrapper(attacker, victim, click_params)
	check_results(attacker, victim, baton)

/datum/unit_test/baton_swings/proc/get_click_params(mob/living/carbon/human/attacker)
	return

/datum/unit_test/baton_swings/proc/prepare_attacker(mob/living/carbon/human/attacker)
	return

/datum/unit_test/baton_swings/proc/check_results(mob/living/carbon/human/attacker, mob/living/carbon/human/victim, obj/item/melee/baton/security/baton)
	TEST_ASSERT(attacker.next_move > world.time, "Attacker did not have a cooldown after swinging a baton")
	TEST_ASSERT(victim.getStaminaLoss() != 0, "Victim did not take stamina damage from a baton swing")
	TEST_ASSERT(!COOLDOWN_FINISHED(baton, cooldown_check), "Baton did not have a cooldown after swinging")

/// Testing baton interaction in which the attacker is on combat mode and is left clicking
/// The baton is on, so all this should do is stun
/datum/unit_test/baton_swings/combat_mode_left_click

/datum/unit_test/baton_swings/combat_mode_left_click/prepare_attacker(mob/living/carbon/human/attacker)
	attacker.set_combat_mode(TRUE)

/datum/unit_test/baton_swings/combat_mode_left_click/get_click_params(mob/living/carbon/human/attacker)
	return list(LEFT_CLICK = TRUE)

/// Testing baton interaction in which the attacker is on combat mode and is right clicking
/// The baton is on, so this should stun and bash - IE, harming while stunning
/datum/unit_test/baton_swings/combat_mode_right_click

/datum/unit_test/baton_swings/combat_mode_right_click/prepare_attacker(mob/living/carbon/human/attacker)
	attacker.set_combat_mode(TRUE)

/datum/unit_test/baton_swings/combat_mode_right_click/get_click_params(mob/living/carbon/human/attacker)
	return list(RIGHT_CLICK = TRUE)

/datum/unit_test/baton_swings/combat_mode_right_click/check_results(mob/living/carbon/human/attacker, mob/living/carbon/human/victim, obj/item/melee/baton/security/baton)
	. = ..()
	TEST_ASSERT(victim.getBruteLoss() != 0, "Victim did not take brute damage from a harmbaton swing")

/// Testing baton interaction in which the attacker is off of combat mode and is left clicking
/// Without combat mode the attacker should not be swinging, so nothing should happen
/datum/unit_test/baton_swings/no_combat_mode_left_click

/datum/unit_test/baton_swings/no_combat_mode_left_click/get_click_params(mob/living/carbon/human/attacker)
	return list(LEFT_CLICK = TRUE)

/datum/unit_test/baton_swings/no_combat_mode_left_click/check_results(mob/living/carbon/human/attacker, mob/living/carbon/human/victim, obj/item/melee/baton/security/baton)
	TEST_ASSERT(victim.getStaminaLoss() == 0, "Victim took stamina damage despite not being hit by any swing")
	TEST_ASSERT(COOLDOWN_FINISHED(baton, cooldown_check), "Baton had a cooldown after failing to swing")

/// Testing baton interaction in which the attacker is off of combat mode and is right clicking
/// Without combat mode the attacker should not be swinging, so nothing should happen
/datum/unit_test/baton_swings/no_combat_mode_right_click

/datum/unit_test/baton_swings/no_combat_mode_right_click/get_click_params(mob/living/carbon/human/attacker)
	return list(RIGHT_CLICK = TRUE)

/datum/unit_test/baton_swings/no_combat_mode_right_click/check_results(mob/living/carbon/human/attacker, mob/living/carbon/human/victim, obj/item/melee/baton/security/baton)
	TEST_ASSERT(attacker.next_move <= world.time, "Attacker had a cooldown despite not being in combat mode / swinging")
	TEST_ASSERT(victim.getStaminaLoss() == 0, "Victim took stamina damage despite not being hit by any swing")
	TEST_ASSERT(COOLDOWN_FINISHED(baton, cooldown_check), "Baton had a cooldown after failing to swing")
