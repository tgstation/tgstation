/// Tests that flashes, well, flash.
/datum/unit_test/flash_click
	var/apply_verb = "while Attacker was not on combat mode"

/datum/unit_test/flash_click/Run()
	var/mob/living/carbon/human/consistent/attacker = EASY_ALLOCATE()
	var/mob/living/carbon/human/consistent/victim = EASY_ALLOCATE()
	var/obj/item/assembly/flash/handheld/flash = EASY_ALLOCATE()

	attacker.put_in_active_hand(flash, forced = TRUE)
	ready_subjects(attacker, victim)
	click_wrapper(attacker, victim)
	check_results(attacker, victim)

/datum/unit_test/flash_click/proc/ready_subjects(mob/living/carbon/human/attacker, mob/living/carbon/human/victim)
	victim.forceMove(locate(attacker.x + 1, attacker.y, attacker.z))
	attacker.face_atom(victim)
	victim.face_atom(attacker)

/datum/unit_test/flash_click/proc/check_results(mob/living/carbon/human/attacker, mob/living/carbon/human/victim)
	TEST_ASSERT_NOTEQUAL(victim.getStaminaLoss(), 0, "Victim should have sustained stamina loss from being flashed head-on [apply_verb].")

/// Tests that flashes flash on combat mode.
/datum/unit_test/flash_click/combat_mode
	apply_verb = "while Attacker was on combat mode"

/datum/unit_test/flash_click/combat_mode/ready_subjects(mob/living/carbon/human/attacker, mob/living/carbon/human/victim)
	. = ..()
	attacker.set_combat_mode(TRUE)

/// Tests that flashes do not flash if wearing protection.
/datum/unit_test/flash_click/flash_protection
	apply_verb = "while wearing flash protection"

/datum/unit_test/flash_click/flash_protection/ready_subjects(mob/living/carbon/human/attacker, mob/living/carbon/human/victim)
	. = ..()
	var/obj/item/clothing/glasses/sunglasses/glasses = EASY_ALLOCATE()
	victim.equip_to_appropriate_slot(glasses)

/datum/unit_test/flash_click/flash_protection/check_results(mob/living/carbon/human/attacker, mob/living/carbon/human/victim)
	TEST_ASSERT_EQUAL(victim.getStaminaLoss(), 0, "Victim should not have sustained stamina loss from being flashed head-on [apply_verb].")
