GLOBAL_LIST_INIT(lawset_laws, get_lawset_laws())

/proc/get_lawset_laws()
	. = list()

	var/datum/ai_laws/lawset_datum = null

	for(var/lawset in subtypesof(/datum/ai_laws))
		lawset_datum = new lawset

		.["[lawset]"] = list()

		.["[lawset]"][LAW_NAME] = lawset_datum.name

		.["[lawset]"][LAW_ZEROTH] = lawset_datum.zeroth

		.["[lawset]"][LAW_HACKED] = list()

		.["[lawset]"][LAW_HACKED] = lawset_datum.hacked

		.["[lawset]"][LAW_ION] = list()

		.["[lawset]"][LAW_ION] = lawset_datum.ion

		.["[lawset]"][LAW_INHERENT] = list()

		.["[lawset]"][LAW_INHERENT] = lawset_datum.inherent

		.["[lawset]"][LAW_SUPPLIED] = list()

		.["[lawset]"][LAW_SUPPLIED] = lawset_datum.supplied

GLOBAL_LIST_INIT(lawset_law_lists, get_lawset_law_lists())

/proc/get_lawset_law_lists()
	. = list()

	var/datum/ai_laws/lawset_datum = new /datum/ai_laws

	for(var/lawset in subtypesof(/datum/ai_laws))
		lawset_datum.set_laws_lawset("[lawset]")

		.[lawset_datum.name] = lawset_datum.get_law_list(TRUE, FALSE, FALSE)
