/*

Usage:
Override /Run() to run your test code

Call TEST_FAIL() to fail the test (You should specify a reason)

You may use /New() and /Destroy() for setup/teardown respectively

You can use the run_loc_floor_bottom_left and run_loc_floor_top_right to get turfs for testing

*/

GLOBAL_DATUM(current_test, /datum/unit_test)
GLOBAL_VAR_INIT(failed_any_test, FALSE)
/// When unit testing, all logs sent to log_mapping are stored here and retrieved in log_mapping unit test.
GLOBAL_LIST_EMPTY(unit_test_mapping_logs)
/// Global assoc list of required mapping items, [item typepath] to [required item datum].
GLOBAL_LIST_EMPTY(required_map_items)

/// A list of every test that is currently focused.
/// Use the PERFORM_ALL_TESTS macro instead.
GLOBAL_VAR_INIT(focused_tests, focused_tests())

/proc/focused_tests()
	var/list/focused_tests = list()
	for (var/datum/unit_test/unit_test as anything in subtypesof(/datum/unit_test))
		if (initial(unit_test.focus))
			focused_tests += unit_test

	return focused_tests.len > 0 ? focused_tests : null

/datum/unit_test
	//Bit of metadata for the future maybe
	var/list/procs_tested

	/// The bottom left floor turf of the testing zone
	var/turf/run_loc_floor_bottom_left

	/// The top right floor turf of the testing zone
	var/turf/run_loc_floor_top_right
	///The priority of the test, the larger it is the later it fires
	var/priority = TEST_DEFAULT
	//internal shit
	var/focus = FALSE
	var/succeeded = TRUE
	var/list/allocated
	var/list/fail_reasons

	/// Do not instantiate if type matches this
	var/abstract_type = /datum/unit_test

	/// List of atoms that we don't want to ever initialize in an agnostic context, like for Create and Destroy. Stored on the base datum for usability in other relevant tests that need this data.
	var/static/list/uncreatables = null

	var/static/datum/space_level/reservation

/proc/cmp_unit_test_priority(datum/unit_test/a, datum/unit_test/b)
	return initial(a.priority) - initial(b.priority)

/datum/unit_test/New()
	if (isnull(reservation))
		var/datum/map_template/unit_tests/template = new
		reservation = template.load_new_z()

	if (isnull(uncreatables))
		uncreatables = build_list_of_uncreatables()

	allocated = new
	run_loc_floor_bottom_left = get_turf(locate(/obj/effect/landmark/unit_test_bottom_left) in GLOB.landmarks_list)
	run_loc_floor_top_right = get_turf(locate(/obj/effect/landmark/unit_test_top_right) in GLOB.landmarks_list)

	TEST_ASSERT(isfloorturf(run_loc_floor_bottom_left), "run_loc_floor_bottom_left was not a floor ([run_loc_floor_bottom_left])")
	TEST_ASSERT(isfloorturf(run_loc_floor_top_right), "run_loc_floor_top_right was not a floor ([run_loc_floor_top_right])")

/datum/unit_test/Destroy()
	QDEL_LIST(allocated)
	// clear the test area
	for (var/turf/turf in Z_TURFS(run_loc_floor_bottom_left.z))
		for (var/content in turf.contents)
			if (istype(content, /obj/effect/landmark))
				continue
			qdel(content)
	return ..()

/datum/unit_test/proc/Run()
	TEST_FAIL("[type]/Run() called parent or not implemented")

/datum/unit_test/proc/Fail(reason = "No reason", file = "OUTDATED_TEST", line = 1)
	succeeded = FALSE

	if(!istext(reason))
		reason = "FORMATTED: [reason != null ? reason : "NULL"]"

	LAZYADD(fail_reasons, list(list(reason, file, line)))

/// Allocates an instance of the provided type, and places it somewhere in an available loc
/// Instances allocated through this proc will be destroyed when the test is over
/datum/unit_test/proc/allocate(type, ...)
	var/list/arguments = args.Copy(2)
	if(ispath(type, /atom))
		if (!arguments.len)
			arguments = list(run_loc_floor_bottom_left)
		else if (arguments[1] == null)
			arguments[1] = run_loc_floor_bottom_left
	var/instance
	// Byond will throw an index out of bounds if arguments is empty in that arglist call. Sigh
	if(length(arguments))
		instance = new type(arglist(arguments))
	else
		instance = new type()
	allocated += instance
	return instance

/// Resets the air of our testing room to its default
/datum/unit_test/proc/restore_atmos()
	var/area/working_area = run_loc_floor_bottom_left.loc
	var/list/turf/to_restore = working_area.get_turfs_from_all_zlevels()
	for(var/turf/open/restore in to_restore)
		var/datum/gas_mixture/GM = SSair.parse_gas_string(restore.initial_gas_mix, /datum/gas_mixture/turf)
		restore.copy_air(GM)
		restore.temperature = initial(restore.temperature)
		restore.air_update_turf(update = FALSE, remove = FALSE)

/datum/unit_test/proc/test_screenshot(name, icon/icon)
	if (!istype(icon))
		TEST_FAIL("[icon] is not an icon.")
		return

	var/path_prefix = replacetext(replacetext("[type]", "/datum/unit_test/", ""), "/", "_")
	name = replacetext(name, "/", "_")

	var/filename = "code/modules/unit_tests/screenshots/[path_prefix]_[name].png"

	if (fexists(filename))
		var/data_filename = "data/screenshots/[path_prefix]_[name].png"
		fcopy(icon, data_filename)
		log_test("\t[path_prefix]_[name] was found, putting in data/screenshots")
	else
#ifdef CIBUILDING
		// We are runing in real CI, so just pretend it worked and move on
		fcopy(icon, "data/screenshots_new/[path_prefix]_[name].png")

		log_test("\t[path_prefix]_[name] was put in data/screenshots_new")
#else
		// We are probably running in a local build
		fcopy(icon, filename)
		TEST_FAIL("Screenshot for [name] did not exist. One has been created.")
#endif


/// Helper for screenshot tests to take an image of an atom from all directions and insert it into one icon
/datum/unit_test/proc/get_flat_icon_for_all_directions(atom/thing, no_anim = TRUE)
	var/icon/output = icon('icons/effects/effects.dmi', "nothing")

	for (var/direction in GLOB.cardinals)
		var/icon/partial = getFlatIcon(thing, defdir = direction, no_anim = no_anim)
		output.Insert(partial, dir = direction)

	return output

/// Logs a test message. Will use GitHub action syntax found at https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions
/datum/unit_test/proc/log_for_test(text, priority, file, line)
	var/map_name = SSmapping.current_map.map_name

	// Need to escape the text to properly support newlines.
	var/annotation_text = replacetext(text, "%", "%25")
	annotation_text = replacetext(annotation_text, "\n", "%0A")

	log_world("::[priority] file=[file],line=[line],title=[map_name]: [type]::[annotation_text]")

/**
 * Helper to perform a click
 *
 * * clicker: The mob that will be clicking
 * * clicked_on: The atom that will be clicked
 * * passed_params: A list of parameters to pass to the click
 */
/datum/unit_test/proc/click_wrapper(mob/living/clicker, atom/clicked_on, list/passed_params = list(LEFT_CLICK = 1, BUTTON = LEFT_CLICK))
	clicker.next_click = -1
	clicker.next_move = -1
	clicker.ClickOn(clicked_on, list2params(passed_params))

/proc/RunUnitTest(datum/unit_test/test_path, list/test_results)
	if(ispath(test_path, /datum/unit_test/focus_only))
		return

	if(initial(test_path.abstract_type) == test_path)
		return

	var/datum/unit_test/test = new test_path

	GLOB.current_test = test
	var/duration = REALTIMEOFDAY
	var/skip_test = (test_path in SSmapping.current_map.skipped_tests)
	var/test_output_desc = "[test_path]"
	var/message = ""

	log_world("::group::[test_path]")

	if(skip_test)
		log_world("[TEST_OUTPUT_YELLOW("SKIPPED")] Skipped run on map [SSmapping.current_map.map_name].")

	else

		test.Run()
		test.restore_atmos()

		duration = REALTIMEOFDAY - duration
		GLOB.current_test = null
		GLOB.failed_any_test |= !test.succeeded

		var/list/log_entry = list()
		var/list/fail_reasons = test.fail_reasons

		for(var/reasonID in 1 to LAZYLEN(fail_reasons))
			var/text = fail_reasons[reasonID][1]
			var/file = fail_reasons[reasonID][2]
			var/line = fail_reasons[reasonID][3]

			test.log_for_test(text, "error", file, line)

			// Normal log message
			log_entry += "\tFAILURE #[reasonID]: [text] at [file]:[line]"

		if(length(log_entry))
			message = log_entry.Join("\n")
			log_test(message)

		test_output_desc += " [duration / 10]s"
		if (test.succeeded)
			log_world("[TEST_OUTPUT_GREEN("PASS")] [test_output_desc]")

	log_world("::endgroup::")

	if (!test.succeeded && !skip_test)
		log_world("::error::[TEST_OUTPUT_RED("FAIL")] [test_output_desc]")

	var/final_status = skip_test ? UNIT_TEST_SKIPPED : (test.succeeded ? UNIT_TEST_PASSED : UNIT_TEST_FAILED)
	test_results[test_path] = list("status" = final_status, "message" = message, "name" = test_path)

	qdel(test)

/// Builds (and returns) a list of atoms that we shouldn't initialize in generic testing, like Create and Destroy.
/// It is appreciated to add the reason why the atom shouldn't be initialized if you add it to this list.
/datum/unit_test/proc/build_list_of_uncreatables()
	RETURN_TYPE(/list)
	var/list/returnable_list = list()
	// The following are just generic, singular types.
	returnable_list = list(
		//Never meant to be created, errors out the ass for mobcode reasons
		/mob/living/carbon,
		//And another
		/obj/item/slimecross/recurring,
		//This should be obvious
		/obj/machinery/doomsday_device,
		//Yet more templates
		/obj/machinery/restaurant_portal,
		//Template type
		/obj/machinery/power/turbine,
		//Template type
		/obj/effect/mob_spawn,
		//Template type
		/obj/structure/holosign/robot_seat,
		//Singleton
		/mob/dview,
		//Template type
		/obj/item/bodypart,
		//This is meant to fail extremely loud every single time it occurs in any environment in any context, and it falsely alarms when this unit test iterates it. Let's not spawn it in.
		/obj/merge_conflict_marker,
		//briefcase launchpads erroring
		/obj/machinery/launchpad/briefcase,
		//Wings abstract path
		/obj/item/organ/wings,
		//Not meant to spawn without the machine wand
		/obj/effect/bug_moving,
		//The abstract grown item expects a seed, but doesn't have one
		/obj/item/food/grown,
		///Single use case holder atom requiring a user
		/atom/movable/looking_holder,
	)

	// Everything that follows is a typesof() check.

	//Say it with me now, type template
	returnable_list += typesof(/obj/effect/mapping_helpers)
	//This turf existing is an error in and of itself
	returnable_list += typesof(/turf/baseturf_skipover)
	returnable_list += typesof(/turf/baseturf_bottom)
	//This demands a borg, so we'll let if off easy
	returnable_list += typesof(/obj/item/modular_computer/pda/silicon)
	//This one demands a computer, ditto
	returnable_list += typesof(/obj/item/modular_computer/processor)
	//Very finiky, blacklisting to make things easier
	returnable_list += typesof(/obj/item/poster/wanted)
	//Needs clients / mobs to observe it to exist. Also includes hallucinations.
	returnable_list += typesof(/obj/effect/client_image_holder)
	//Same to above. Needs a client / mob / hallucination to observe it to exist.
	returnable_list += typesof(/obj/projectile/hallucination)
	returnable_list += typesof(/obj/item/hallucinated)
	//We don't have a pod
	returnable_list += typesof(/obj/effect/pod_landingzone_effect)
	returnable_list += typesof(/obj/effect/pod_landingzone)
	//We have a baseturf limit of 10, adding more than 10 baseturf helpers will kill CI, so here's a future edge case to fix.
	returnable_list += typesof(/obj/effect/baseturf_helper)
	//No tauma to pass in
	returnable_list += typesof(/mob/eye/imaginary_friend)
	//No heart to give
	returnable_list += typesof(/obj/structure/ethereal_crystal)
	//No linked console
	returnable_list += typesof(/mob/eye/camera/remote/base_construction)
	//See above
	returnable_list += typesof(/mob/eye/camera/remote/shuttle_docker)
	//Hangs a ref post invoke async, which we don't support. Could put a qdeleted check but it feels hacky
	returnable_list += typesof(/obj/effect/anomaly/grav/high)
	//See above
	returnable_list += typesof(/obj/effect/timestop)
	//Sparks can ignite a number of things, causing a fire to burn the floor away. Only you can prevent CI fires
	returnable_list += typesof(/obj/effect/particle_effect/sparks)
	//See above - These are one of those things.
	returnable_list += typesof(/obj/effect/decal/cleanable/fuel_pool)
	//Invoke async in init, skippppp
	returnable_list += typesof(/mob/living/silicon/robot/model)
	//This lad also sleeps
	returnable_list += typesof(/obj/item/hilbertshotel)
	//this boi spawns turf changing stuff, and it stacks and causes pain. Let's just not
	returnable_list += typesof(/obj/effect/sliding_puzzle)
	//these can explode and cause the turf to be destroyed at unexpected moments
	returnable_list += typesof(/obj/effect/mine)
	returnable_list += typesof(/obj/effect/spawner/random/contraband/landmine)
	returnable_list += typesof(/obj/item/minespawner)
	//Stacks baseturfs, can't be tested here
	returnable_list += typesof(/obj/effect/temp_visual/lava_warning)
	//Stacks baseturfs, can't be tested here
	returnable_list += typesof(/obj/effect/landmark/ctf)
	//Our system doesn't support it without warning spam from unregister calls on things that never registered
	returnable_list += typesof(/obj/docking_port)
	//Asks for a shuttle that may not exist, let's leave it alone
	returnable_list += typesof(/obj/item/pinpointer/shuttle)
	//This spawns beams as a part of init, which can sleep past an async proc. This hangs a ref, and fucks us. It's only a problem here because the beam sleeps with CHECK_TICK
	returnable_list += typesof(/obj/structure/alien/resin/flower_bud)
	//Needs a linked mecha
	returnable_list += typesof(/obj/effect/skyfall_landingzone)
	//Expects a mob to holderize, we have nothing to give
	returnable_list += typesof(/obj/item/mob_holder)
	//Needs cards passed into the initilazation args
	returnable_list += typesof(/obj/item/toy/cards/cardhand)
	//Needs a holodeck area linked to it which is not guarenteed to exist and technically is supposed to have a 1:1 relationship with computer anyway.
	returnable_list += typesof(/obj/machinery/computer/holodeck)
	//runtimes if not paired with a landmark
	returnable_list += typesof(/obj/structure/transport/linear)
	// Runtimes if the associated machinery does not exist, but not the base type
	returnable_list += subtypesof(/obj/machinery/airlock_controller)
	// Always ought to have an associated escape menu. Any references it could possibly hold would need one regardless.
	returnable_list += subtypesof(/atom/movable/screen/escape_menu)
	// Can't spawn openspace above nothing, it'll get pissy at me
	returnable_list += typesof(/turf/open/space/openspace)
	returnable_list += typesof(/turf/open/openspace)
	returnable_list += typesof(/obj/item/robot_model) // These should never be spawned outside of a robot.

	return returnable_list

/proc/RunUnitTests()
	CHECK_TICK

	var/list/tests_to_run = subtypesof(/datum/unit_test)
	var/list/focused_tests = list()
	for (var/_test_to_run in tests_to_run)
		var/datum/unit_test/test_to_run = _test_to_run
		if (initial(test_to_run.focus))
			focused_tests += test_to_run
	if(length(focused_tests))
		tests_to_run = focused_tests

	sortTim(tests_to_run, GLOBAL_PROC_REF(cmp_unit_test_priority))

	var/list/test_results = list()

	//Hell code, we're bound to end the round somehow so let's stop if from ending while we work
	SSticker.delay_end = TRUE
	for(var/unit_path in tests_to_run)
		CHECK_TICK //We check tick first because the unit test we run last may be so expensive that checking tick will lock up this loop forever
		RunUnitTest(unit_path, test_results)
	SSticker.delay_end = FALSE

	var/file_name = "data/unit_tests.json"
	fdel(file_name)
	file(file_name) << json_encode(test_results)

	SSticker.force_ending = ADMIN_FORCE_END_ROUND
	//We have to call this manually because del_text can preceed us, and SSticker doesn't fire in the post game
	SSticker.declare_completion()

/datum/map_template/unit_tests
	name = "Unit Tests Zone"
	mappath = "_maps/templates/unit_tests.dmm"
