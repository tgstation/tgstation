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

/datum/unit_test
	//Bit of metadata for the future maybe
	var/list/procs_tested

	/// The bottom left turf of the testing zone
	var/turf/run_loc_bottom_left

	/// The top right turf of the testing zone
	var/turf/run_loc_top_right

	/// The type of turf to allocate for the testing zone
	var/test_turf_type = /turf/open/floor/plasteel

	//internal shit
	var/focus = FALSE
	var/succeeded = TRUE
	var/list/allocated
	var/list/fail_reasons

	var/static/datum/turf_reservation/turf_reservation

/datum/unit_test/New()
	if (isnull(turf_reservation))
		turf_reservation = SSmapping.RequestBlockReservation(5, 5)

	for (var/turf/reserved_turf in turf_reservation.reserved_turfs)
		reserved_turf.ChangeTurf(test_turf_type)

	allocated = new
	run_loc_bottom_left = locate(turf_reservation.bottom_left_coords[1], turf_reservation.bottom_left_coords[2], turf_reservation.bottom_left_coords[3])
	run_loc_top_right = locate(turf_reservation.top_right_coords[1], turf_reservation.top_right_coords[2], turf_reservation.top_right_coords[3])

/datum/unit_test/Destroy()
	//clear the test area
	for(var/atom/movable/AM in block(run_loc_bottom_left, run_loc_top_right))
		qdel(AM)
	QDEL_LIST(allocated)
	return ..()

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

	SSticker.force_ending = TRUE
