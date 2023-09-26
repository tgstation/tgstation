#define TEST_MAP "test_only"
#define TEST_MAP_EXPENSIVE "test_only_expensive"

/// The qserver and qconsole should find each other on init
/datum/unit_test/qserver_find_console

/datum/unit_test/qserver_find_console/Run()
	var/obj/machinery/computer/quantum_console/console = allocate(/obj/machinery/computer/quantum_console)
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))

	TEST_ASSERT_NOTNULL(console.server_ref, "Quantum console did not set server_ref")
	TEST_ASSERT_NOTNULL(server.console_ref, "Quantum server did not set console_ref")

	var/obj/machinery/computer/quantum_console/connected_console = server.console_ref.resolve()
	var/obj/machinery/quantum_server/connected_server = console.server_ref.resolve()
	TEST_ASSERT_EQUAL(connected_console, console, "Quantum console did not set server_ref correctly")
	TEST_ASSERT_EQUAL(connected_server, server, "Quantum server did not set console_ref correctly")

/// Tests the connection between avatar and pilot
/datum/unit_test/avatar_connection_basic

/datum/unit_test/avatar_connection_basic/Run()
	var/obj/machinery/netpod/pod = allocate(/obj/machinery/netpod)
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human/consistent)

	labrat.mind_initialize()
	labrat.mock_client = new()

	var/datum/weakref/initial_mind = labrat.mind
	var/datum/weakref/labrat_mind_ref = WEAKREF(labrat.mind)
	pod.occupant = labrat

	var/datum/component/avatar_connection/connection = target.AddComponent( \
		/datum/component/avatar_connection, \
		old_mind = labrat.mind, \
		old_body = labrat, \
		server = server, \
		pod = pod, \
	)

	var/mob/living/carbon/human/labrat_resolved = connection.old_body_ref?.resolve()
	TEST_ASSERT_EQUAL(labrat, labrat_resolved, "Wrong pilot ref")

	var/obj/machinery/netpod/connected_pod = connection.netpod_ref?.resolve()
	TEST_ASSERT_EQUAL(connected_pod, pod, "Wrong netpod ref")

	target.apply_damage(10, damagetype = BURN, def_zone = BODY_ZONE_HEAD, blocked = 0, forced = TRUE)
	TEST_ASSERT_EQUAL(labrat.getFireLoss(), 10, "Damage was not transferred to pilot")
	TEST_ASSERT_NOTNULL(locate(/obj/item/bodypart/head) in labrat.get_damaged_bodyparts(burn = TRUE), "Pilot did not get damaged bodypart")

	connection.full_avatar_disconnect()
	TEST_ASSERT_EQUAL(labrat.mind, initial_mind, "Should reconnect mind on full disconnect")

	for(var/i in 1 to 5) // so sick of this failing
		target.apply_damage(500, damagetype = BURN, def_zone = BODY_ZONE_HEAD, blocked = 0, forced = TRUE, spread_damage = TRUE)
	TEST_ASSERT_EQUAL(target.stat, DEAD, "Target should be very dead")
	TEST_ASSERT_NOTEQUAL(labrat.stat, DEAD, "Pilot should be very alive")

/// Gibbing specifically
/datum/unit_test/avatar_connection_gib

/datum/unit_test/avatar_connection_gib/Run()
	var/obj/machinery/netpod/pod = allocate(/obj/machinery/netpod)
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))

	var/mob/living/carbon/human/to_gib = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/pincushion = allocate(/mob/living/carbon/human/consistent)
	pincushion.mind_initialize()
	pincushion.mock_client = new()
	var/datum/mind/initial_mind = pincushion.mind
	pod.occupant = pincushion

	to_gib.AddComponent( \
		/datum/component/avatar_connection, \
		old_mind = pincushion.mind, \
		old_body = pincushion, \
		server = server, \
		pod = pod, \
	)

	to_gib.gib()
	TEST_ASSERT_EQUAL(initial_mind, pincushion.mind, "Pilot should have been transferred back on avatar gib")
	TEST_ASSERT_EQUAL(pincushion.get_organ_loss(ORGAN_SLOT_BRAIN), pod.disconnect_damage, "Pilot should have taken brain dmg on gib disconnect")

/// Tests the server's ability to generate a loot crate
/datum/unit_test/qserver_generate_rewards

/datum/unit_test/qserver_generate_rewards/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)
	labrat.mind_initialize()
	labrat.mock_client = new()

	var/turf/tiles = get_adjacent_open_turfs(server)
	TEST_ASSERT_NOTEQUAL(length(tiles), 0, "Sanity: Did not find an open turf")

	server.cold_boot_map(labrat, map_key = TEST_MAP)
	TEST_ASSERT_EQUAL(server.generated_domain.key, TEST_MAP, "Sanity: Did not load test map correctly")

	server.receive_turfs = tiles
	TEST_ASSERT_EQUAL(server.generate_loot(), TRUE, "Should generate loot with a receive turf")

/// Server side randomization of domains
/datum/unit_test/qserver_get_random_domain_id

/datum/unit_test/qserver_get_random_domain_id/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)

	var/id = server.get_random_domain_id()
	TEST_ASSERT_NULL(id, "Shouldn't return a random domain with no points")

	server.points = 3
	id = server.get_random_domain_id()
	TEST_ASSERT_NOTNULL(id, "Should return a random domain with points")

/// Tests the ability to create hololadders and effectively, retries
/datum/unit_test/qserver_generate_hololadder

/datum/unit_test/qserver_generate_hololadder/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)

	server.generate_hololadder()
	TEST_ASSERT_EQUAL(length(server.exit_turfs), 0, "Sanity: Shouldn't exist any exit turfs until boot")
	TEST_ASSERT_EQUAL(server.retries_spent, 0, "Shouldn't create a hololadder without exit turfs")

	server.cold_boot_map(labrat, map_key = TEST_MAP)
	TEST_ASSERT_NOTNULL(server.generated_domain, "Sanity: Did not load test map correctly")
	TEST_ASSERT_EQUAL(length(server.exit_turfs), 3, "Should create 3 exit turfs")

	server.generate_hololadder()
	TEST_ASSERT_EQUAL(server.retries_spent, 1, "Should've spent a retry")

	server.generate_hololadder()
	server.generate_hololadder()
	TEST_ASSERT_EQUAL(server.retries_spent, 3, "Should've spent 3 retries")

	server.generate_hololadder()
	TEST_ASSERT_EQUAL(server.retries_spent, 3, "Shouldn't spend more than 3 retries")

	server.reset(fast = TRUE)
	TEST_ASSERT_EQUAL(server.retries_spent, 0, "Should reset retries on reset()")

/// Tests the calculate rewards function
/datum/unit_test/qserver_calculate_rewards

/datum/unit_test/qserver_calculate_rewards/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)
	var/datum/weakref/labrat_mind_ref = WEAKREF(labrat.mind)

	server.cold_boot_map(labrat, map_key = TEST_MAP)
	TEST_ASSERT_NOTNULL(server.generated_domain, "Sanity: Did not load test map correctly")

	var/rewards = server.calculate_rewards()
	TEST_ASSERT_EQUAL(rewards, 1, "Should return base rewards when unmodded")

	server.domain_randomized = TRUE
	rewards = server.calculate_rewards()
	TEST_ASSERT_EQUAL(rewards, 1.2, "Should increase rewards when randomized")

	server.domain_randomized = FALSE
	server.avatar_connection_refs += labrat_mind_ref
	server.avatar_connection_refs += labrat_mind_ref
	server.avatar_connection_refs += labrat_mind_ref
	rewards = server.calculate_rewards()
	var/totalA = ROUND_UP(rewards)
	var/totalB = ROUND_UP(1 + server.multiplayer_bonus * 2)
	TEST_ASSERT_EQUAL(totalA, totalB, "Should increase rewards with occupants")

	for(var/datum/stock_part/servo/servo in server.component_parts)
		server.component_parts -= servo
		server.component_parts += new /datum/stock_part/servo/tier4

	server.RefreshParts()
	server.avatar_connection_refs.Cut()
	rewards = server.calculate_rewards()
	TEST_ASSERT_EQUAL(rewards, 1.6, "Should increase rewards with modded servos")

/// Ensures loot crates can spawn a proper number of items
/datum/unit_test/bitrunning_loot_crate_rewards

/datum/unit_test/bitrunning_loot_crate_rewards/Run()
	var/obj/structure/closet/crate/secure/bitrunning/decrypted/crate = allocate(/obj/structure/closet/crate/secure/bitrunning/decrypted)

	var/total = 0
	total = crate.calculate_loot(1, 1, 1)
	TEST_ASSERT_NOTEQUAL(total, 0, "Should return a number")

	total = crate.calculate_loot(1, 1, 3)
	TEST_ASSERT_NOTEQUAL(total, 0, "Should return a number")

	total = crate.calculate_loot(1, 1, 0.5)
	TEST_ASSERT_NOTEQUAL(total, 0, "Should return a number")

	total = crate.calculate_loot(3, 4, 0.3)
	TEST_ASSERT_NOTEQUAL(total, 0, "Should return a number")

	total = crate.calculate_loot(3, 3.2, 0.2)
	TEST_ASSERT_NOTEQUAL(total, 0, "Should return a number")

/// Ensures settings on vdoms are being set correctly
/datum/unit_test/bitrunner_vdom_settings

/datum/unit_test/bitrunner_vdom_settings/Run()
	var/obj/structure/closet/crate/secure/bitrunning/decrypted/crate = allocate(/obj/structure/closet/crate/secure/bitrunning/decrypted)

	for(var/path in subtypesof(/datum/lazy_template/virtual_domain))
		var/datum/lazy_template/virtual_domain/vdom = new path
		TEST_ASSERT_NOTNULL(vdom.key, "[path] should have a key")
		TEST_ASSERT_NOTNULL(vdom.map_name, "[path] should have a map name")

		if(!length(vdom.extra_loot))
			continue

		TEST_ASSERT_EQUAL(crate.spawn_loot(vdom.extra_loot), TRUE, "[path] didn't spawn loot. Extra loot should be an associative list")

#undef TEST_MAP
#undef TEST_MAP_EXPENSIVE
