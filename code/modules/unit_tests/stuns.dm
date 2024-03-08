/// Tests stun and the canstun flag
/datum/unit_test/stun

/datum/unit_test/stun/Run()
	var/mob/living/carbon/human/gets_stunned = allocate(/mob/living/carbon/human/consistent)

	gets_stunned.Stun(1 SECONDS)
	TEST_ASSERT(gets_stunned.IsStun(), "Stun() failed to apply stun")

	gets_stunned.SetStun(0 SECONDS)
	TEST_ASSERT(!gets_stunned.IsStun(), "SetStun(0) failed to clear stun")

	gets_stunned.status_flags &= ~CANSTUN
	gets_stunned.Stun(1 SECONDS)
	TEST_ASSERT(!gets_stunned.IsStun(), "Stun() stunned despite not having CANSTUN flag")

/// Tests knockdown and the canknockdown flag
/datum/unit_test/knockdown

/datum/unit_test/knockdown/Run()
	var/mob/living/carbon/human/gets_knockdown = allocate(/mob/living/carbon/human/consistent)

	gets_knockdown.Knockdown(1 SECONDS)
	TEST_ASSERT(gets_knockdown.IsKnockdown(), "Knockdown() failed to apply knockdown")

	gets_knockdown.SetKnockdown(0 SECONDS)
	TEST_ASSERT(!gets_knockdown.IsKnockdown(), "SetKnockdown(0) failed to clear knockdown")

	gets_knockdown.status_flags &= ~CANKNOCKDOWN
	gets_knockdown.Knockdown(1 SECONDS)
	TEST_ASSERT(!gets_knockdown.IsKnockdown(), "Knockdown() knocked over despite not having CANKNOCKDOWN flag")

/// Tests paralyze and stuns that have two flags checked (in this case, canstun and canknockdown)
/datum/unit_test/paralyze

/datum/unit_test/paralyze/Run()
	var/mob/living/carbon/human/gets_paralyzed = allocate(/mob/living/carbon/human/consistent)

	gets_paralyzed.Paralyze(1 SECONDS)
	TEST_ASSERT(gets_paralyzed.IsParalyzed(), "Paralyze() failed to apply paralyze")

	gets_paralyzed.SetParalyzed(0 SECONDS)
	TEST_ASSERT(!gets_paralyzed.IsParalyzed(), "SetParalyzed(0) failed to clear paralyze")

	gets_paralyzed.status_flags &= ~CANSTUN // paralyze needs both CANSTUN and CANKNOCKDOWN to succeed
	gets_paralyzed.Paralyze(1 SECONDS)
	TEST_ASSERT(!gets_paralyzed.IsParalyzed(), "Paralyze() paralyzed a mob despite not having CANSTUN flag (but still having CANKNOCKDOWN)")

/// Tests unconsciousness and the canunconscious flag
/datum/unit_test/unconsciousness

/datum/unit_test/unconsciousness/Run()
	var/mob/living/carbon/human/gets_unconscious = allocate(/mob/living/carbon/human/consistent)

	gets_unconscious.Unconscious(1 SECONDS)
	TEST_ASSERT(gets_unconscious.IsUnconscious(), "Unconscious() failed to apply unconsciousness")

	gets_unconscious.SetUnconscious(0 SECONDS)
	TEST_ASSERT(!gets_unconscious.IsUnconscious(), "SetUnconscious(0) failed to clear unconsciousness")

	gets_unconscious.status_flags &= ~CANUNCONSCIOUS
	gets_unconscious.Unconscious(1 SECONDS)
	TEST_ASSERT(!gets_unconscious.IsUnconscious(), "Unconscious() knocked unconscious despite not having CANUNCONSCIOUS flag")

/// Tests for stun absorption
/datum/unit_test/stun_absorb

/datum/unit_test/stun_absorb/Run()
	var/mob/living/carbon/human/doesnt_get_stunned = allocate(/mob/living/carbon/human/consistent)
	doesnt_get_stunned.add_stun_absorption(source = TRAIT_SOURCE_UNIT_TESTS)
	doesnt_get_stunned.Stun(1 SECONDS)
	TEST_ASSERT(!doesnt_get_stunned.IsStun(), "Stun() stunned despite having stun absorption")
