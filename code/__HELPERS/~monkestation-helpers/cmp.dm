/proc/cmp_mob_playtime_asc(mob/a, mob/b)
	return cmp_numeric_asc(a?.client?.get_exp_living(TRUE), b?.client?.get_exp_living(TRUE))

/proc/cmp_mob_playtime_dsc(mob/a, mob/b)
	return cmp_numeric_dsc(a?.client?.get_exp_living(TRUE), b?.client?.get_exp_living(TRUE))

/// Sorts between two wounds, descending by their severity.
/// Use when you want a list of most to least severe wounds.
/proc/cmp_wound_severity_dsc(datum/wound/a, datum/wound/b)
	return cmp_numeric_dsc(a.severity, b.severity)
