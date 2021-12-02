#define COMSIG_MOCK_SIGNAL "mock_signal"

/// Test that the connect_loc element handles basic movement cases
/datum/unit_test/connect_loc_basic

/datum/unit_test/connect_loc_basic/Run()
	var/obj/item/watches_mock_calls/watcher = allocate(/obj/item/watches_mock_calls)

	var/turf/current_turf = get_turf(watcher)

	SEND_SIGNAL(current_turf, COMSIG_MOCK_SIGNAL)
	TEST_ASSERT_EQUAL(watcher.times_called, 1, "After firing mock signal, connect_loc didn't send it")

	watcher.forceMove(run_loc_floor_top_right)

	SEND_SIGNAL(current_turf, COMSIG_MOCK_SIGNAL)
	TEST_ASSERT_EQUAL(watcher.times_called, 1, "Mock signal was fired on old turf, but connect_loc still picked it up")

	current_turf = get_turf(watcher)
	SEND_SIGNAL(current_turf, COMSIG_MOCK_SIGNAL)
	TEST_ASSERT_EQUAL(watcher.times_called, 2, "Mock signal was fired after turf move, but it wasn't picked up")

/// Test that the connect_loc element handles turf changes
/datum/unit_test/connect_loc_change_turf
	var/old_turf_type

/datum/unit_test/connect_loc_change_turf/Run()
	var/obj/item/watches_mock_calls/watcher = allocate(/obj/item/watches_mock_calls, run_loc_floor_bottom_left)

	var/turf/current_turf = get_turf(watcher)
	old_turf_type = current_turf.type

	SEND_SIGNAL(current_turf, COMSIG_MOCK_SIGNAL)
	TEST_ASSERT_EQUAL(watcher.times_called, 1, "After firing mock signal, connect_loc didn't send it")

	current_turf.ChangeTurf(/turf/closed/wall)

	SEND_SIGNAL(current_turf, COMSIG_MOCK_SIGNAL)
	TEST_ASSERT_EQUAL(watcher.times_called, 2, "After changing turf, connect_loc didn't reconnect it")

	current_turf.ChangeTurf(/turf/open/floor/carpet)
	SEND_SIGNAL(current_turf, COMSIG_MOCK_SIGNAL)
	TEST_ASSERT_EQUAL(watcher.times_called, 3, "After changing turf a second time, connect_loc didn't reconnect it")

/datum/unit_test/connect_loc_change_turf/Destroy()
	run_loc_floor_bottom_left.ChangeTurf(old_turf_type)
	return ..()

/// Tests that multiple objects can have connect_loc on the same turf without runtimes.
/datum/unit_test/connect_loc_multiple_on_turf

/datum/unit_test/connect_loc_multiple_on_turf/Run()
	var/obj/item/watches_mock_calls/watcher_one = allocate(/obj/item/watches_mock_calls, run_loc_floor_bottom_left)
	qdel(watcher_one)

	var/obj/item/watches_mock_calls/watcher_two = allocate(/obj/item/watches_mock_calls, run_loc_floor_bottom_left)
	qdel(watcher_two)

/obj/item/watches_mock_calls
	var/times_called

/obj/item/watches_mock_calls/Initialize(mapload)
	. = ..()

	var/static/list/connections = list(
		COMSIG_MOCK_SIGNAL = .proc/on_receive_mock_signal,
	)

	AddElement(/datum/element/connect_loc, connections)

/obj/item/watches_mock_calls/proc/on_receive_mock_signal(datum/source)
	SIGNAL_HANDLER
	times_called += 1

#undef COMSIG_MOCK_SIGNAL
