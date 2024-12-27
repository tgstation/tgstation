/// Tests hulk attacking over normal attacking
/datum/unit_test/hulk_attack
	var/hulk_hits = 0
	var/hand_hits = 0

/datum/unit_test/hulk_attack/Run()
	var/mob/living/carbon/human/hulk = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)


	RegisterSignal(dummy, COMSIG_ATOM_HULK_ATTACK, PROC_REF(hulk_sig_fire))
	RegisterSignal(dummy, COMSIG_ATOM_ATTACK_HAND, PROC_REF(hand_sig_fire))

	hulk.dna.add_mutation(/datum/mutation/human/hulk)
	hulk.set_combat_mode(TRUE)
	hulk.ClickOn(dummy)

	TEST_ASSERT_EQUAL(hulk_hits, 1, "Hulk should have hit the dummy once.")
	TEST_ASSERT_EQUAL(hand_hits, 0, "Hulk should not have hit the dummy with attack_hand.")
	TEST_ASSERT(dummy.getBruteLoss(), "Dummy should have taken brute damage from being hulk punched.")

/datum/unit_test/hulk_attack/proc/hulk_sig_fire()
	SIGNAL_HANDLER
	hulk_hits += 1

/datum/unit_test/hulk_attack/proc/hand_sig_fire()
	SIGNAL_HANDLER
	hand_hits += 1

/// Tests that hulks aren't given rapid attacks from rapid attack gloves
/datum/unit_test/hulk_north_star

/datum/unit_test/hulk_north_star/Run()
	var/mob/living/carbon/human/hulk = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/clothing/gloves/rapid/fotns = allocate(/obj/item/clothing/gloves/rapid)

	hulk.equip_to_appropriate_slot(fotns)
	hulk.dna.add_mutation(/datum/mutation/human/hulk)
	hulk.set_combat_mode(TRUE)
	hulk.ClickOn(dummy)

	TEST_ASSERT_NOTEQUAL(hulk.next_move, world.time + CLICK_CD_RAPID, "Hulk should not gain the effects of the Fists of the North Star.")
	TEST_ASSERT_EQUAL(hulk.next_move, world.time + CLICK_CD_MELEE, "Hulk click cooldown was a value not expected.")
