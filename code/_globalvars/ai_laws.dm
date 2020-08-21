GLOBAL_LIST_INIT(lawset_laws, get_laws())

/proc/gets_laws()
	. = list()

	var/datum/ai_laws/lawset_datum = null

	for(var/lawset in subtypesof(/datum/ai_laws))
		lawset_datum = new lawset

		..Add(lawset_datum.get_law_list(TRUE, FALSE, FALSE))
