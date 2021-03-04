/// Verifies that roundstart dynamic rulesets are setup properly without external configuration.
/datum/unit_test/dynamic_roundstart_ruleset_sanity

/datum/unit_test/dynamic_roundstart_ruleset_sanity/Run()
	for (var/_ruleset in subtypesof(/datum/dynamic_ruleset/roundstart))
		var/datum/dynamic_ruleset/roundstart/ruleset = _ruleset

		var/has_scaling_cost = initial(ruleset.scaling_cost)
		var/is_lone = initial(ruleset.flags) & (LONE_RULESET | HIGH_IMPACT_RULESET)

		if (has_scaling_cost && is_lone)
			Fail("[ruleset] has a scaling_cost, but is also a lone/highlander ruleset.")
		else if (!has_scaling_cost && !is_lone)
			Fail("[ruleset] has no scaling cost, but is also not a lone/highlander ruleset.")
