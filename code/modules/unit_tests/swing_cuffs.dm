/// Tests that handcuffs can be applied.
/datum/unit_test/apply_cuffs
	var/apply_verb = "not on combat mode"
	var/cuff_attempts = 0

/datum/unit_test/apply_cuffs/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/restraints/handcuffs/cuffs = allocate(/obj/item/restraints/handcuffs)

	attacker.put_in_active_hand(cuffs, forced = TRUE)
	ready_attacker(attacker)
	RegisterSignal(victim, COMSIG_CARBON_CUFF_ATTEMPTED, PROC_REF(cuff_tried))

	click_wrapper(attacker, victim)
	TEST_ASSERT_EQUAL(cuff_attempts, 1, "Failed to attempt a handcuff while [apply_verb].")

/datum/unit_test/apply_cuffs/proc/ready_attacker(mob/living/carbon/human/attacker)
	return

/datum/unit_test/apply_cuffs/proc/cuff_tried()
	SIGNAL_HANDLER
	cuff_attempts++

/// Tests that handcuffs can be applied while in combat mode.
/datum/unit_test/apply_cuffs/combat_mode
	apply_verb = "on combat mode"

/datum/unit_test/apply_cuffs/combat_mode/ready_attacker(mob/living/carbon/human/attacker)
	attacker.set_combat_mode(TRUE)
