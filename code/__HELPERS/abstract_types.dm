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

/proc/valid_subtypes(datum/sometype)
	return subtypesof(sometype) - get_abstract_types()
