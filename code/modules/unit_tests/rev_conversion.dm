/// Tests that headrevs can convert people by clicking on them with flashes
/datum/unit_test/revolution_conversion

/datum/unit_test/revolution_conversion/Run()
	var/mob/living/carbon/human/leader = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/peasant = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	var/datum/client_interface/leader_client = new()
	var/datum/client_interface/peasant_client = new()

	leader.mind_initialize()
	leader.mock_client = leader_client
	peasant.mind_initialize()
	peasant.mock_client = peasant_client

	var/datum/antagonist/rev/head/lead_datum = leader.mind.add_antag_datum(/datum/antagonist/rev/head)
	var/datum/team/revolution/revolution = lead_datum.get_team()

	var/obj/item/assembly/flash/handheld/converter = new()
	leader.put_in_active_hand(converter, forced = TRUE)
	leader.ClickOn(peasant)

	TEST_ASSERT_EQUAL(length(revolution.members), 2, "Expected revolution to have 2 members after the leader flashes the peasant.")
