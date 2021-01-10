/*

Usage:
Override /Run() to run your test code

Call Fail() to fail the test (You should specify a reason)

You may use /New() and /Destroy() for setup/teardown respectively

You can use the run_loc_bottom_left and run_loc_top_right to get turfs for testing

*/

GLOBAL_DATUM(current_test, /datum/unit_test)
GLOBAL_VAR_INIT(failed_any_test, FALSE)
GLOBAL_VAR(test_log)

/// Set to false to disable cleanup after testing, leaving test environments and server running for inspection
#define CLEANUP_AFTER_TEST FALSE
// although so many of the unit tests just spawn humans to then choke and die in space :(

/datum/unit_test
	//Bit of metadata for the future maybe
	var/list/procs_tested

	/// The bottom left turf of the testing zone
	var/turf/run_loc_bottom_left

	/// The top right turf of the testing zone
	var/turf/run_loc_top_right

	/// The type of turf to allocate for the testing zone
	var/test_turf_type = /turf/open/floor/plasteel

	/// The type of turf IF ANY to have the outer testing zone set to
	var/border_test_turf_type = null

	/// How many turfs the reserved area is wide
	var/reservation_width = 5
	/// How many turfs the reserved area is high
	var/reservation_height = 5
	/// Whether to force gravity in the testing area
	var/gravity = FALSE

	//internal shit
	var/focus = FALSE
	var/succeeded = TRUE
	var/list/allocated
	var/list/fail_reasons


	var/static/datum/turf_reservation/turf_reservation

/datum/unit_test/New()
	if (isnull(turf_reservation))
		turf_reservation = SSmapping.RequestBlockReservation(reservation_width, reservation_height)

	for (var/turf/reserved_turf in turf_reservation.reserved_turfs)
		var/turf_type = test_turf_type
		if(border_test_turf_type)
			if(reserved_turf.x == turf_reservation.bottom_left_coords[1] || reserved_turf.x == turf_reservation.top_right_coords[1] || reserved_turf.y == turf_reservation.bottom_left_coords[2] || reserved_turf.y == turf_reservation.top_right_coords[2])
				turf_type = border_test_turf_type

		reserved_turf.ChangeTurf(turf_type)
		if(gravity)
			reserved_turf.AddElement(/datum/element/forced_gravity)

	allocated = new
	run_loc_bottom_left = locate(turf_reservation.bottom_left_coords[1], turf_reservation.bottom_left_coords[2], turf_reservation.bottom_left_coords[3])
	run_loc_top_right = locate(turf_reservation.top_right_coords[1], turf_reservation.top_right_coords[2], turf_reservation.top_right_coords[3])

/datum/unit_test/Destroy()
	if(CLEANUP_AFTER_TEST)
		clear_test_area()
		QDEL_LIST(allocated)
	else
		// Drop references to all test contents so they don't get swept up by GC
		allocated = null
		turf_reservation = null
		run_loc_top_right = null
		run_loc_bottom_left = null
	return ..()

/// Clear the test area of all movable atoms.
/datum/unit_test/proc/clear_test_area()
	for(var/atom/movable/AM in block(run_loc_bottom_left, run_loc_top_right))
		qdel(AM)

/datum/unit_test/proc/Run()
	Fail("Run() called parent or not implemented")

/datum/unit_test/proc/Fail(reason = "No reason")
	succeeded = FALSE

	if(!istext(reason))
		reason = "FORMATTED: [reason != null ? reason : "NULL"]"

	LAZYADD(fail_reasons, reason)

/// Allocates an instance of the provided type, and places it somewhere in an available loc
/// Instances allocated through this proc will be destroyed when the test is over
/datum/unit_test/proc/allocate(type, ...)
	var/list/arguments = args.Copy(2)
	if (!arguments.len)
		arguments = list(run_loc_bottom_left)
	else if (arguments[1] == null)
		arguments[1] = run_loc_bottom_left
	var/instance = new type(arglist(arguments))
	allocated += instance
	return instance

/proc/RunUnitTests()
	CHECK_TICK

	var/tests_to_run = subtypesof(/datum/unit_test)
	for (var/_test_to_run in tests_to_run)
		var/datum/unit_test/test_to_run = _test_to_run
		if (initial(test_to_run.focus))
			tests_to_run = list(test_to_run)
			break

	for(var/I in tests_to_run)
		var/datum/unit_test/test = new I

		GLOB.current_test = test
		var/duration = REALTIMEOFDAY

		test.Run()

		duration = REALTIMEOFDAY - duration
		GLOB.current_test = null
		GLOB.failed_any_test |= !test.succeeded

		var/list/log_entry = list("[test.succeeded ? "PASS" : "FAIL"]: [I] [duration / 10]s")
		var/list/fail_reasons = test.fail_reasons

		qdel(test)

		for(var/J in 1 to LAZYLEN(fail_reasons))
			log_entry += "\tREASON #[J]: [fail_reasons[J]]"
		log_test(log_entry.Join("\n"))

		CHECK_TICK

	if(CLEANUP_AFTER_TEST)
		SSticker.force_ending = TRUE

#undef CLEANUP_AFTER_TEST
