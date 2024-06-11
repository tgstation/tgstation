/datum/reagent/drug/methamphetamine
	var/safe = FALSE

// Double the OD treshold, no brain damage or addiction
/datum/reagent/drug/methamphetamine/borer_version
	name = "Unknown Methamphetamine Isomer"
	overdose_threshold = 40
	addiction_types = null
	safe = TRUE
