/datum/unit_test/emoting
	var/emotes_used = 0

/datum/unit_test/emoting/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	RegisterSignal(human, COMSIG_MOB_EMOTE, PROC_REF(on_emote_used))

	human.say("*shrug")
	TEST_ASSERT_EQUAL(emotes_used, 1, "Human did not shrug")

	human.say("*beep")
	TEST_ASSERT_EQUAL(emotes_used, 1, "Human beeped, when that should be restricted to silicons")

	human.setOxyLoss(140)

	TEST_ASSERT(human.stat != CONSCIOUS, "Human is somehow conscious after receiving suffocation damage")

	human.say("*shrug")
	TEST_ASSERT_EQUAL(emotes_used, 1, "Human shrugged while unconscious")

	human.say("*deathgasp")
	TEST_ASSERT_EQUAL(emotes_used, 2, "Human could not deathgasp while unconscious")

/datum/unit_test/emoting/proc/on_emote_used()
	SIGNAL_HANDLER
	emotes_used += 1
