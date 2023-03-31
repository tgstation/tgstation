/// Tests that headrevs can convert people by clicking on them with flashes
/datum/unit_test/revolution_conversion

/datum/unit_test/revolution_conversion/Run()
	var/mob/living/carbon/human/leader = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/peasant = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)

	leader.mind_initialize()
	leader.mock_client = new()
	peasant.mind_initialize()
	peasant.mock_client = new()

	var/datum/antagonist/rev/head/lead_datum = leader.mind.add_antag_datum(/datum/antagonist/rev/head)
	var/datum/team/revolution/revolution = lead_datum.get_team()

	var/obj/item/assembly/flash/handheld/converter = allocate(/obj/item/assembly/flash/handheld)
	leader.put_in_active_hand(converter, forced = TRUE)
	leader.ClickOn(peasant)

	TEST_ASSERT(peasant.IsParalyzed(), "Peasant was not paralyzed after being flashed by the leader") // Flash paralyze
	TEST_ASSERT(peasant.IsStun(), "Peasant was not stunned after being converted by the leader") // Conversion stun
	TEST_ASSERT_EQUAL(length(revolution.members), 2, "Expected revolution to have 2 members after the leader flashes the peasant.")
