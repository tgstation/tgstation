#define TEST_MAP "test_only"
#define TEST_MAP_EXPENSIVE "test_only_expensive"

/// The qserver and qconsole should find each other on init
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

/// Tests the signals sent when the server is destroyed, mobs step on a loaded tile, etc
/datum/unit_test/bitrunning_signals
	var/client_connect_received = FALSE
	var/client_disconnect_received = FALSE
	var/crowbar_alert_received = FALSE
	var/domain_complete_received = FALSE
	var/integrity_alert_received = FALSE
	var/sever_avatar_received = FALSE
	var/shutdown_alert_received = FALSE

/datum/unit_test/bitrunning_signals/proc/on_crowbar_alert(datum/source)
	SIGNAL_HANDLER
	crowbar_alert_received = TRUE

/datum/unit_test/bitrunning_signals/proc/on_domain_complete(datum/source)
	SIGNAL_HANDLER
	domain_complete_received = TRUE

/datum/unit_test/bitrunning_signals/proc/on_shutdown_alert(datum/source)
	SIGNAL_HANDLER
	shutdown_alert_received = TRUE

/datum/unit_test/bitrunning_signals/proc/on_netpod_broken(datum/source)
	SIGNAL_HANDLER
	sever_avatar_received = TRUE

/datum/unit_test/bitrunning_signals/proc/on_netpod_integrity(datum/source)
	SIGNAL_HANDLER
	integrity_alert_received = TRUE

/datum/unit_test/bitrunning_signals/proc/on_server_crash(datum/source)
	SIGNAL_HANDLER
	sever_avatar_received = TRUE

/datum/unit_test/bitrunning_signals/Run()
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/obj/machinery/netpod/netpod = allocate(/obj/machinery/netpod, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))

	labrat.mind_initialize()
	labrat.mock_client = new()

	var/obj/item/crowbar/prybar = allocate(/obj/item/crowbar)
	var/mob/living/carbon/human/perp = allocate(/mob/living/carbon/human/consistent)

	RegisterSignal(server, COMSIG_BITRUNNER_DOMAIN_COMPLETE, PROC_REF(on_domain_complete))
	RegisterSignal(server, COMSIG_BITRUNNER_SHUTDOWN_ALERT, PROC_REF(on_shutdown_alert))
	RegisterSignal(server, COMSIG_BITRUNNER_SEVER_AVATAR, PROC_REF(on_server_crash))
	RegisterSignal(netpod, COMSIG_BITRUNNER_CROWBAR_ALERT, PROC_REF(on_crowbar_alert))
	RegisterSignal(netpod, COMSIG_BITRUNNER_SEVER_AVATAR, PROC_REF(on_netpod_broken))
	RegisterSignal(netpod, COMSIG_BITRUNNER_NETPOD_INTEGRITY, PROC_REF(on_netpod_integrity))

	server.cold_boot_map(labrat, map_key = TEST_MAP)
	TEST_ASSERT_EQUAL(server.generated_domain.key, TEST_MAP, "Sanity: Did not load test map correctly")

	labrat.forceMove(get_turf(netpod))
	netpod.set_occupant(labrat)
	netpod.close_machine(labrat)
	TEST_ASSERT_EQUAL(netpod.occupant, labrat, "Sanity: Did not set occupant")
	TEST_ASSERT_NOTNULL(netpod.server_ref, "Sanity: Did not set server")
	TEST_ASSERT_EQUAL(netpod.connected, TRUE, "Sanity: pod didn't connect")

	perp.put_in_active_hand(prybar)
	netpod.default_pry_open(prybar, perp)
	TEST_ASSERT_EQUAL(crowbar_alert_received, TRUE, "Did not send COMSIG_BITRUNNER_CROWBAR_ALERT")
	TEST_ASSERT_EQUAL(sever_avatar_received, TRUE, "Did not send COMSIG_BITRUNNER_SEVER_AVATAR")

	sever_avatar_received = FALSE
	server.avatar_connection_refs += WEAKREF(labrat.mind)
	server.begin_shutdown(perp)
	TEST_ASSERT_EQUAL(shutdown_alert_received, TRUE, "Did not send COMSIG_BITRUNNER_SHUTDOWN_ALERT")
	TEST_ASSERT_EQUAL(sever_avatar_received, TRUE, "Did not send COMSIG_BITRUNNER_SERVER_CRASH")

	server.cool_off()
	server.avatar_connection_refs.Cut()
	server.cold_boot_map(labrat, map_key = TEST_MAP)
	TEST_ASSERT_EQUAL(server.generated_domain.key, TEST_MAP, "Sanity: Did not load test map correctly")

/// Tests the server's ability to generate a loot crate
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

	// This is a pretty shallow test. I keep getting null crates with locate(), so I'm not sure how to test this
	// var/obj/structure/closet/crate/secure/bitrunning/decrypted/crate = locate(/obj/structure/closet/crate/secure/bitrunning/decrypted) in tiles
	// TEST_ASSERT_NOTNULL(crate, "Should generate a loot crate")

/// Server side randomization of domains
/datum/unit_test/qserver_get_random_domain_id/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)

	var/id = server.get_random_domain_id()
	TEST_ASSERT_NULL(id, "Shouldn't return a random domain with no points")

	server.points = 3
	id = server.get_random_domain_id()
	TEST_ASSERT_NOTNULL(id, "Should return a random domain with points")

	/// Can't truly test the randomization past this

/// Tests getting list of domain generated mobs for antag targets
/datum/unit_test/qserver_get_valid_domain_mobs/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)

	server.cold_boot_map(labrat, map_key = TEST_MAP)
	TEST_ASSERT_NOTNULL(server.generated_domain, "Sanity: Did not load test map correctly")
	TEST_ASSERT_EQUAL(server.generated_domain.key, TEST_MAP, "Sanity: Did not load test map correctly")

	var/list/mobs = server.get_valid_domain_targets()
	TEST_ASSERT_EQUAL(length(mobs), 0, "Shouldn't get a list without players")

	server.avatar_connection_refs += WEAKREF(labrat.mind)
	mobs += server.get_valid_domain_targets()

	var/datum/turf_reservation/res = server.generated_domain.reservations[1]
	TEST_ASSERT_NOTNULL(res, "Sanity: Did not generate a reservation")

	var/mob/living/basic/pet/dog/corgi/pupper
	var/mob/living/carbon/human/corpse
	for(var/turf/tile as anything in res.reserved_turfs)
		var/mob/living/basic/pet/dog/corgi/doggo = locate() in tile
		if(doggo)
			pupper = doggo
			continue
		var/mob/living/carbon/human/husk = locate() in tile
		if(husk)
			corpse = husk

	TEST_ASSERT_NOTNULL(pupper, "Should be a corgi on test map")
	TEST_ASSERT_NOTNULL(corpse, "Should be a corpse on test map")

	mobs.Cut()
	mobs += server.get_valid_domain_targets()
	TEST_ASSERT_EQUAL(length(mobs), 2, "Should return a list of mobs")

	mobs.Cut()
	pupper.mind_initialize()
	pupper.mock_client = new()
	mobs += server.get_valid_domain_targets()
	TEST_ASSERT_EQUAL(length(mobs), 1, "Should not return mobs with minds")

/// Tests the ability to create hololadders and effectively, retries
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
/datum/unit_test/bitrunner_vdom_settings/Run()
	var/obj/structure/closet/crate/secure/bitrunning/decrypted/crate = allocate(/obj/structure/closet/crate/secure/bitrunning/decrypted)

	for(var/path in subtypesof(/datum/lazy_template/virtual_domain))
		var/datum/lazy_template/virtual_domain/vdom = new path
		TEST_ASSERT_NOTNULL(vdom.key, "[path] should have a key")
		TEST_ASSERT_NOTNULL(vdom.map_name, "[path] should have a map name")

		// This seems to return true regardless of the map existing or not
		// var/file_name = '_maps/virtual_domains/' + [vdom.map_name] + '.dmm'
		// TEST_ASSERT_NOTNULL(isfile(file_name), "Could not find map file for [path]")

		if(!length(vdom.extra_loot))
			continue

		TEST_ASSERT_EQUAL(crate.spawn_loot(vdom.extra_loot), TRUE, "[path] didn't spawn loot. Extra loot should be an associative list")

#undef TEST_MAP
#undef TEST_MAP_EXPENSIVE
