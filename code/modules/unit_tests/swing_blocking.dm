/datum/unit_test/blocking
	abstract_type = /datum/unit_test/blocking
	var/block_descriptor

/datum/unit_test/blocking/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)

	setup_attacker(attacker)
	setup_victim(victim)

	click_wrapper(attacker, victim)

	TEST_ASSERT_EQUAL(victim.getBruteLoss() + victim.getFireLoss(), 0, "Victim took damage despite blocking [block_descriptor].")
	TEST_ASSERT_NOTEQUAL(victim.getStaminaLoss(), 0, "Victim failed to take any stamina from blocking [block_descriptor].")

/datum/unit_test/blocking/proc/setup_attacker(mob/living/carbon/human/attacker)
	attacker.set_combat_mode(TRUE)

/datum/unit_test/blocking/proc/setup_victim(mob/living/carbon/human/victim)
	victim.begin_blocking()

/datum/unit_test/blocking/bare_handed
	block_descriptor = "bare handed"

/datum/unit_test/blocking/shield
	block_descriptor = "with a shield"

/datum/unit_test/blocking/shield/setup_victim(mob/living/carbon/human/victim)
	var/obj/item/shield/riot/shield = allocate(/obj/item/shield/riot)
	victim.put_in_inactive_hand(shield, forced = TRUE)
	return ..()

/datum/unit_test/blocking/shield/with_weapon
	block_descriptor = "with a shield against an attacker with a toolbox"

/datum/unit_test/blocking/shield/with_weapon/setup_attacker(mob/living/carbon/human/attacker)
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)
	attacker.put_in_active_hand(toolbox, forced = TRUE)
	return ..()

/datum/unit_test/no_stam_healing

/datum/unit_test/no_stam_healing/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)

	ADD_TRAIT(victim, TRAIT_CANNOT_HEAL_STAMINA, TRAIT_SOURCE_UNIT_TESTS)
	victim.adjustStaminaLoss(10)
	TEST_ASSERT_EQUAL(victim.getStaminaLoss(), 10, "Victim did not take stamina damage while blocking.")

	victim.adjustStaminaLoss(-10)
	TEST_ASSERT_EQUAL(victim.getStaminaLoss(), 10, "Victim healed stamina damage while blocking.")
