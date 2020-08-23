GLOBAL_LIST_INIT(lawset_law_lists, get_lawset_law_lists())

/proc/get_lawset_law_lists()
	. = list()

	var/datum/ai_laws/lawset_datum = null

	for(var/lawset in subtypesof(/datum/ai_laws))
		lawset_datum = new lawset

		.[lawset_datum.name] = lawset_datum.get_law_list(TRUE, FALSE, FALSE)
