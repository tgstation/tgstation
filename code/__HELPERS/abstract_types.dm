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

/// Like subtypesof, but automatically excludes abstract typepaths
/proc/valid_subtypesof(datum/base_type)
	return valid_typesof(base_type) - base_type

/// Like typesof, but automatically excludes abstract typepaths
/proc/valid_typesof(datum/base_type)
	. = list()
	for (var/datum/type as anything in typesof(base_type))
		if (type != type::abstract_type)
			. += type
