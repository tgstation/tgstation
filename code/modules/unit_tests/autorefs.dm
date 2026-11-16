/datum/unit_test/autoref_resolve_during_qdel
	var/datum/autoref/pen_ref
	var/pen_resolved_during_qdel = FALSE

/datum/unit_test/autoref_resolve_during_qdel/Run()
	var/obj/item/pen/pen = allocate(/obj/item/pen)
	TEST_ASSERT_NULL(pen.auto_reference, "pen should not have an autoref")

	// Listening before creating an autoref ensures this handler run's before the autoref is cleaned up.
	RegisterSignal(pen, COMSIG_QDELETING, PROC_REF(on_pen_qdeleting))
	pen_ref = AUTOREF(pen)
	qdel(pen)

	TEST_ASSERT(!pen_resolved_during_qdel, "pen autoref resolved during qdel")

/datum/unit_test/autoref_resolve_during_qdel/proc/on_pen_qdeleting(datum/source)
	SIGNAL_HANDLER
	pen_resolved_during_qdel = !isnull(pen_ref.resolve())

#define EXPECTED_FLOOR_TYPE /turf/open/floor
// Do this instead of just ChangeTurf to guarantee that baseturfs is completely default on-init behavior
#define RESET_TO_EXPECTED(turf) \
	turf.ChangeTurf(EXPECTED_FLOOR_TYPE);\
	turf.assemble_baseturfs(initial(turf.baseturfs))

/datum/unit_test/autoref_change_turf

/datum/unit_test/autoref_change_turf/Run()
	var/turf/test_turf = run_loc_floor_bottom_left

	var/datum/autoref/turf_ref = AUTOREF(test_turf)
	TEST_ASSERT_EQUAL(turf_ref.resolve(), test_turf, "turf autoref should resolve")

	var/turf/changed_turf = test_turf.ChangeTurf(/turf/open/floor/plating)
	TEST_ASSERT_EQUAL(AUTOREF(changed_turf), turf_ref, "changed turf should keep the same autoref")
	TEST_ASSERT_EQUAL(turf_ref.resolve(), changed_turf, "changed turf's autoref should still resolve")

/datum/unit_test/autoref_change_turf/Destroy()
	RESET_TO_EXPECTED(run_loc_floor_bottom_left)
	return ..()

#undef RESET_TO_EXPECTED
#undef EXPECTED_FLOOR_TYPE
