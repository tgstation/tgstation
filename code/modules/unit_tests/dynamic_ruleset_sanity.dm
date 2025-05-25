/// Verifies that dynamic rulesets are setup properly without external configuration.
/datum/unit_test/dynamic_ruleset_sanity

/datum/unit_test/dynamic_ruleset_sanity/Run()
	for (var/datum/dynamic_ruleset/midround/ruleset as anything in subtypesof(/datum/dynamic_ruleset/midround))
		if(!initial(ruleset.config_tag))
			continue
		var/midround_ruleset_style = initial(ruleset.midround_type)
		if (midround_ruleset_style != HEAVY_MIDROUND && midround_ruleset_style != LIGHT_MIDROUND)
			TEST_FAIL("[ruleset] has an invalid midround_ruleset_style, it should be HEAVY_MIDROUND or LIGHT_MIDROUND")

/// Verifies that dynamic rulesets have unique antag_flag.
/datum/unit_test/dynamic_unique_antag_flags

/datum/unit_test/dynamic_unique_antag_flags/Run()
	var/list/known_antag_flags = list()

	for (var/datum/dynamic_ruleset/ruleset as anything in subtypesof(/datum/dynamic_ruleset))
		if(!initial(ruleset.config_tag))
			continue

		var/antag_flag = initial(ruleset.pref_flag)

		// null antag flag is valid for rulesets with no associated preferecne
		if (isnull(antag_flag))
			// however if you set preview_antag_datum, it is assumed you do have a preference, and thus should have a flag
			if (initial(ruleset.preview_antag_datum))
				TEST_FAIL("[ruleset] sets preview_antag_datum, but has no pref_flag! \
					If you want to use a preview antag datum, you must set a pref_flag.")
			continue

		if (antag_flag in known_antag_flags)
			TEST_FAIL("[ruleset] has a non-unique antag_flag [antag_flag] (used by [known_antag_flags[antag_flag]])!")
			continue

		known_antag_flags[antag_flag] = ruleset
