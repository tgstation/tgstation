/datum/unit_test/factions
	var/emotes_used = 0

/datum/unit_test/factions/Run()

	var/mob/living/alice = allocate(/mob/living)

	// tests innate traits on init.
	TEST_ASSERT(HAS_TRAIT(alice, TRAIT_FACTION_NEUTRAL), "Alice (base living mob) doesn't have the FACTION_NEUTRAL innate trait")

	// innate traits changes.
	alice.reset_innate_factions(TRAIT_FACTION_SILICON)
	TEST_ASSERT(!HAS_TRAIT(alice, TRAIT_FACTION_NEUTRAL), "Alice still has the FACTION_NEUTRAL innate trait after reset_innate_traits(TRAIT_FACTION_SILICON) was called")
	TEST_ASSERT(HAS_TRAIT(alice, TRAIT_FACTION_SILICON), "Alice doesn't have the FACTION_SILICON innate trait after reset_innate_traits(TRAIT_FACTION_SILICON) was called")

	var/mob/living/charlie = allocate(/mob/living)

	// faction check before faction bind
	TEST_ASSERT(!alice.faction_check(charlie), "alice.faction_check(charlie) succeeded though Alice and Charlie should have no faction in common")

	// faction check after faction bind
	alice.AddComponent(/datum/component/faction_bind, charlie, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT(alice.faction_check(charlie), "alice.faction_check(charlie) failed though Alice has a faction_bind component with Charlie as her faction_master")

	var/mob/living/bob = allocate(/mob/living)

	// faction check on a third party whose factions coincide with the faction master's.
	TEST_ASSERT(alice.faction_check(bob), "alice.faction_check(bob) failed though Charlie (the faction_master of Alice's faction_bind comp) and Bob should have factions in common")

	// same as above, but factions no longer coincide and bob also has a faction_bind comp with charlie as master.
	charlie.reset_innate_factions(TRAIT_FACTION_HOSTILE)
	bob.AddComponent(/datum/component/faction_bind, charlie, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT(alice.faction_check(bob), "alice.faction_check(bob) failed though Alice and Bob both having faction bind components with the same faction_master, Charlie")
