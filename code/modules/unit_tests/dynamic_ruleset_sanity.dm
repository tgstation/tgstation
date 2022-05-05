/// Verifies that roundstart dynamic rulesets are setup properly without external configuration.
/datum/unit_test/dynamic_roundstart_ruleset_sanity

/datum/unit_test/dynamic_roundstart_ruleset_sanity/Run()
	for (var/_ruleset in subtypesof(/datum/dynamic_ruleset/roundstart))
		var/datum/dynamic_ruleset/roundstart/ruleset = _ruleset

		var/has_scaling_cost = initial(ruleset.scaling_cost)
		var/is_lone = initial(ruleset.flags) & (LONE_RULESET | HIGH_IMPACT_RULESET)

		if (has_scaling_cost && is_lone)
			TEST_FAIL("[ruleset] has a scaling_cost, but is also a lone/highlander ruleset.")
		else if (!has_scaling_cost && !is_lone)
			TEST_FAIL("[ruleset] has no scaling cost, but is also not a lone/highlander ruleset.")

/// Verifies that dynamic rulesets have unique antag_flag.
/datum/unit_test/dynamic_unique_antag_flags

/datum/unit_test/dynamic_unique_antag_flags/Run()
	var/list/known_antag_flags = list()

	for (var/datum/dynamic_ruleset/ruleset as anything in subtypesof(/datum/dynamic_ruleset))
		if (isnull(initial(ruleset.antag_datum)))
			continue

		var/antag_flag = initial(ruleset.antag_flag)

		if (isnull(antag_flag))
			TEST_FAIL("[ruleset] has a null antag_flag!")
			continue

		if (antag_flag in known_antag_flags)
			TEST_FAIL("[ruleset] has a non-unique antag_flag [antag_flag] (used by [known_antag_flags[antag_flag]])!")
			continue

		known_antag_flags[antag_flag] = ruleset
