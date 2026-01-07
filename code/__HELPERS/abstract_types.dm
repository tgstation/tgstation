/// Returns a list of all abstract typepaths for all datums
/proc/get_abstract_types()
	var/static/list/abstracts
	if(abstracts)
		return abstracts
	abstracts = list()
	for(var/datum/sometype as anything in subtypesof(/datum))
		if(sometype == sometype::abstract_type)
			abstracts[sometype::abstract_type] = TRUE

	return abstracts

/// Like subtypesof, but automatically excludes abstract typepaths
/proc/valid_subtypesof(datum/sometype)
	return subtypesof(sometype) - get_abstract_types()

/// Like typesof, but automatically excludes abstract typepaths
/proc/valid_typesof(datum/sometype)
	return typesof(sometype) - get_abstract_types()

/// Returns a list of concrete types under abstract sub-branches of `root`
/proc/get_abstract_branch_descendants(datum/root)
	var/list/abstracts = get_abstract_types()
	var/list/to_remove = list()
	var/list/seen_abstract_parents = list()

	for (var/datum/sometype as anything in subtypesof(root))
		if (abstracts[sometype])
			continue

		var/datum/parenttype = sometype.parent_type
		while (parenttype && parenttype != root)
			if (seen_abstract_parents[parenttype] || (abstracts[parenttype]))
				seen_abstract_parents[parenttype] = TRUE
				to_remove += sometype
				break
			parenttype = parenttype.parent_type

	return to_remove

/// Like valid_subtypesof(), but excludes concrete descendants of abstract sub-branches
/proc/valid_direct_subtypesof(datum/root)
	var/list/result = subtypesof(root)

	// Remove all abstract types
	result -= get_abstract_types()

	// Remove concrete types under abstract sub-branches
	result -= get_abstract_branch_descendants(root)

	return result

/// Like valid_typesof(), but excludes concrete descendants of abstract sub-branches
/proc/valid_direct_typesof(datum/root)
	var/list/result = typesof(root)

	// Remove all abstract types
	result -= get_abstract_types()

	// Remove concrete types under abstract sub-branches
	result -= get_abstract_branch_descendants(root)

	return result
