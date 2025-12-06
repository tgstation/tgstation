/// Returns a list of all abstract typepaths for all datums
/proc/get_abstract_types()
	var/static/list/abstracts
	if(abstracts)
		return abstracts
	abstracts = list()
	for(var/datum/sometype as anything in subtypesof(/datum))
		if(sometype == sometype::abstract_type)
			abstracts |= sometype::abstract_type
	return abstracts

// The time complexity of these two procs is really bad, sitting at O(n * m).
// And yet, the overhead is ridiculously small for some reason. We never figured out why.
// So doing list subtraction instead of filtering is faster in all cases, at least for now.
// If we ever breach like 3000-5000 abstract types, that will likely change.
// As of right now we're at 272 or so, with subtraction being ~10x faster.
// Curse this language, for you shall live in hell alongside me.

/// Like subtypesof, but automatically excludes abstract typepaths
/proc/valid_subtypesof(datum/base_type)
	return subtypesof(base_type) - get_abstract_types()

/// Like typesof, but automatically excludes abstract typepaths
/proc/valid_typesof(datum/base_type)
	return typesof(base_type) - get_abstract_types()
