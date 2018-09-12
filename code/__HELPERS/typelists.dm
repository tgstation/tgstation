GLOBAL_LIST_EMPTY(typelists)

/datum/proc/typelist(key, list/values)
	if (!values)
		values = list()
#ifdef TESTING
	GLOB.typelistkeys |= key
#endif
	if (GLOB.typelists[type])
		if (GLOB.typelists[type][key])
#ifdef TESTING
			GLOB.typelists[type]["[key]-saved"]++
#endif
			return GLOB.typelists[type][key]
		else
			GLOB.typelists[type][key] = values.Copy()
	else
		GLOB.typelists[type] = list()
		GLOB.typelists[type][key] = values.Copy()
	return GLOB.typelists[type][key]

#ifdef TESTING
GLOBAL_LIST_EMPTY(typelistkeys)

/proc/tallytypelistsavings()
	var/savings = list()
	for (var/key in GLOB.typelistkeys)
		savings[key] = 0

	for (var/type in GLOB.typelists)
		for (var/saving in savings)
			if (GLOB.typelists[type]["[saving]-saved"])
				savings[saving] += GLOB.typelists[type]["[saving]-saved"]

	for (var/saving in savings)
		to_chat(world, "Savings for [saving]: [savings[saving]]")
#endif
