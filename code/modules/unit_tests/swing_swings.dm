/**
 * Used to test swings.
 */
/datum/unit_test/check_swings
	abstract_type = /datum/unit_test/check_swings
	// These are all stored on the datum itself for ease of access, to not bother about passing them around via args
	var/mob/living/carbon/human/attacker
	var/mob/living/carbon/human/victim_A
	var/mob/living/carbon/human/victim_B
	var/mob/living/carbon/human/victim_C
	var/mob/living/carbon/human/victim_D

/datum/unit_test/check_swings/Destroy()
	attacker = null
	victim_A = null
	victim_B = null
	victim_C = null
	victim_D = null
	return ..()

/*
 * All this parent call is for is to set up a consistent environment to test swings in.
 *
 * The setup:
 *
 * [] .  .  VA
 * [] .  A  VB
 * [] .  VD VC
 * [] [] [] []
 */
/datum/unit_test/check_swings/Run()
	attacker = allocate(/mob/living/carbon/human/consistent)
	victim_A = allocate(/mob/living/carbon/human/consistent)
	victim_B = allocate(/mob/living/carbon/human/consistent)
	victim_C = allocate(/mob/living/carbon/human/consistent)
	victim_D = allocate(/mob/living/carbon/human/consistent)

	attacker.forceMove(locate(attacker.x + 1, attacker.y + 1, attacker.z))
	victim_A.forceMove(locate(attacker.x + 1, attacker.y + 1, attacker.z))
	victim_B.forceMove(locate(attacker.x + 1, attacker.y, attacker.z))
	victim_C.forceMove(locate(attacker.x + 1, attacker.y - 1, attacker.z))
	victim_D.forceMove(locate(attacker.x, attacker.y - 1, attacker.z))

/datum/unit_test/check_swings/melee_three_tiles
	abstract_type = /datum/unit_test/check_swings/melee_three_tiles
	var/assertion_message = ""

/datum/unit_test/check_swings/melee_three_tiles/proc/get_clicking_atom()
	return

/datum/unit_test/check_swings/melee_three_tiles/Run()
	. = ..()

	var/obj/item/melee/baseball_bat/bat = allocate(/obj/item/melee/baseball_bat)
	attacker.put_in_active_hand(bat, forced = TRUE)

	var/atom/clicking_on = get_clicking_atom()
	click_wrapper(attacker, clicking_on)
	if(isliving(clicking_on))
		var/mob/living/living_clicked = clicking_on
		TEST_ASSERT_EQUAL(living_clicked.lastattacker, null, "Victim should not have been hit when clicked on by attacker[assertion_message]")
		TEST_ASSERT_EQUAL(living_clicked.getBruteLoss(), 0, "Victim should not have sustained damage from being clicked on by attacker[assertion_message]")

	attacker.set_combat_mode(TRUE)

	click_wrapper(attacker, clicking_on)
	TEST_ASSERT(attacker.next_move > world.time, "Attacker should have executed a swing, but failed")

	// A is hit
	TEST_ASSERT_NOTEQUAL(victim_A.getBruteLoss(), 0, "Victim A did not sustain damage from being hit by the attacker[assertion_message]")
	TEST_ASSERT_EQUAL(victim_A.lastattacker, attacker.real_name, "Victim A should have been hit by attacker[assertion_message]")

	// B is hit
	TEST_ASSERT_NOTEQUAL(victim_B.getBruteLoss(), 0, "Victim B did not sustain damage from being hit by the attacker[assertion_message]")
	TEST_ASSERT_EQUAL(victim_B.lastattacker, attacker.real_name, "Victim B should have been hit by attacker[assertion_message]")

	// C is hit
	TEST_ASSERT_NOTEQUAL(victim_C.getBruteLoss(), 0, "Victim C did not sustain damage from being hit by the attacker[assertion_message]")
	TEST_ASSERT_EQUAL(victim_C.lastattacker, attacker.real_name, "Victim C should have been hit by attacker[assertion_message]")

	// D is not hit, they are adjacent to attacker
	TEST_ASSERT_EQUAL(victim_D.getBruteLoss(), 0, "Victim D sustained damage from being hit by the attacker[assertion_message], when it should not have been")
	TEST_ASSERT_NOTEQUAL(victim_D.lastattacker, attacker.real_name, "Victim D was hit by attacker[assertion_message], when it should not have been")

/datum/unit_test/check_swings/melee_three_tiles/living_clicked
	assertion_message = " clicking on victim B"

/datum/unit_test/check_swings/melee_three_tiles/living_clicked/get_clicking_atom()
	return victim_B

/datum/unit_test/check_swings/melee_three_tiles/adjacent_turf
	assertion_message = " clicking on victim B's turf"

/datum/unit_test/check_swings/melee_three_tiles/adjacent_turf/get_clicking_atom()
	return get_turf(victim_B)

/datum/unit_test/check_swings/melee_three_tiles/distant_turf
	assertion_message = " clicking on turf beyond victim B"

/datum/unit_test/check_swings/melee_three_tiles/distant_turf/get_clicking_atom()
	return locate(victim_B.x + 1, victim_B.y, victim_B.z)

/datum/unit_test/check_swings/desword

/datum/unit_test/check_swings/desword/Run()
	. = ..()

	var/obj/item/dualsaber/desword = allocate(/obj/item/dualsaber)
	desword.attack_style = GLOB.attack_styles[/datum/attack_style/melee_weapon/swing/desword]
	attacker.put_in_active_hand(desword, forced = TRUE)
	desword.attack_self(attacker)
	attacker.set_combat_mode(TRUE)

	click_wrapper(attacker, victim_B)

	TEST_ASSERT_EQUAL(victim_A.lastattacker, attacker.real_name, "Victim A (to the top right) was not hit by the desword.")
	TEST_ASSERT_NOTEQUAL(victim_A.getBruteLoss(), 0, "Victim A did not sustain damage from being hit by the desword.")

	TEST_ASSERT_EQUAL(victim_B.lastattacker, attacker.real_name, "Victim B (to the direct right) was not hit by the desword.")
	TEST_ASSERT_NOTEQUAL(victim_B.getBruteLoss(), 0, "Victim B did not sustain damage from being hit by the desword.")

	TEST_ASSERT_EQUAL(victim_C.lastattacker, attacker.real_name, "Victim C (to the bottom right) was not hit by the desword.")
	TEST_ASSERT_NOTEQUAL(victim_C.getBruteLoss(), 0, "Victim C did not sustain damage from being hit by the desword.")

	TEST_ASSERT_EQUAL(victim_D.lastattacker, attacker.real_name, "Victim D (to the direct bottom) was not hit by the desword.")
	TEST_ASSERT_NOTEQUAL(victim_D.getBruteLoss(), 0, "Victim D did not sustain damage from being hit by the desword.")
