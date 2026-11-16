// Ensures subystem flags are set in a coherent way
/datum/unit_test/subsystem_flags

/datum/unit_test/subsystem_flags/Run()
	for(var/datum/controller/subsystem/sub_lad as anything in subtypesof(/datum/controller/subsystem))
		if((sub_lad::ss_flags & (SS_TICKER | SS_KEEP_TIMING)) == (SS_TICKER | SS_KEEP_TIMING))
			var/list/matching = get_matching_bitflags("ss_flags", sub_lad::ss_flags)
			TEST_FAIL("[sub_lad] {[matching.Join(" | ")]} had both SS_TICKER and SEE_KEEP_TIMING set, this is redundant! You should likely remove SS_KEEP_TIMING.")
		if((sub_lad::ss_flags & (SS_POST_FIRE_TIMING | SS_KEEP_TIMING)) == (SS_POST_FIRE_TIMING | SS_KEEP_TIMING))
			var/list/matching = get_matching_bitflags("ss_flags", sub_lad::ss_flags)
			TEST_FAIL("[sub_lad] {[matching.Join(" | ")]} had both SS_POST_FIRE_TIMING and SEE_KEEP_TIMING set, this is redundant! You should likely remove SS_KEEP_TIMING as SS_POST_FIRE_TIMING overrides it.")

