/// Tests spy bounty setup
/datum/unit_test/spy_bounty

/datum/unit_test/spy_bounty/Run()
	var/mob/living/carbon/human/james_bond = allocate(/mob/living/carbon/human/consistent)
	james_bond.mind_initialize()
	james_bond.equipOutfit(/datum/outfit/job/assistant/consistent)
	var/datum/antagonist/spy/spy = james_bond.mind.add_antag_datum(/datum/antagonist/spy)

	var/datum/component/spy_uplink/uplink = spy.uplink_weakref?.resolve()
	TEST_ASSERT_NOTNULL(uplink, "Spy failed to be given an uplink!")

	var/datum/spy_bounty_handler/handler = uplink.handler
	handler.num_attempts_override = 100

	for(var/difficulty in handler.possible_uplink_items)
		var/list/loot_pool = handler.possible_uplink_items[difficulty]
		if(!length(loot_pool))
			TEST_FAIL("No rewards generated for spy bounty difficulty [difficulty]")

	for(var/difficulty in UNLINT(handler.bounty_types))
		var/list/bounty_type_pool = UNLINT(handler.bounty_types[difficulty])
		if(!length(bounty_type_pool))
			TEST_FAIL("No bounty types for spy bounty difficulty [difficulty] found")

	for(var/difficulty in UNLINT(handler.bounties))
		var/list/generated_bounties = UNLINT(handler.bounties[difficulty])
		if(difficulty == SPY_DIFFICULTY_HARD)
			if(length(generated_bounties))
				TEST_FAIL("No [difficulty] bounties should not be generated on initial refresh!")

		else
			if(!length(generated_bounties))
				TEST_FAIL("No bounties were generated on initial refresh for difficulty [difficulty]")

	handler.force_refresh()

	for(var/difficulty in UNLINT(handler.bounties))
		var/list/generated_bounties = UNLINT(handler.bounties[difficulty])
		if(!length(generated_bounties))
			TEST_FAIL("No bounties were generated on first refresh for difficulty [difficulty]")
