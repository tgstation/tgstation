GLOBAL_LIST_INIT(lawset_datums, get_lawset_datums())

/proc/get_lawset_datums()
	. = list()

	for(var/lawset in subtypesof(/datum/ai_laws))
		.[lawset] = new lawset

GLOBAL_LIST_INIT(lawset_law_lists, get_lawset_law_lists())

/proc/get_lawset_law_lists()
	. = list()

	var/datum/ai_laws/lawset_datum = new /datum/ai_laws

	for(var/lawset in subtypesof(/datum/ai_laws))
		lawset_datum.set_laws_lawset(lawset)

		.[lawset_datum.name] = lawset_datum.get_law_list(TRUE, FALSE, FALSE).Copy()

	qdel(lawset_datum)
