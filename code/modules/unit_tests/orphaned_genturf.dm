/// Ensures we do not leave genturfs sitting around post work
/// They serve as notice to the mapper and have no functionality, but it's good to make note of it here
/datum/unit_test/orphaned_genturf

/datum/unit_test/orphaned_genturf/Run()
	for(var/turf/open/genturf/orphaned in ALL_TURFS())
		TEST_FAIL("Floating genturf ([orphaned.type]) detected at ([orphaned.x], [orphaned.y], [orphaned.z]) : [orphaned.loc.type]. Why was it not replaced?")
