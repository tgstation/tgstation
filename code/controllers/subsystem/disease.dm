SUBSYSTEM_DEF(disease)
	name = "Disease"
	flags = SS_NO_FIRE

	var/list/active_diseases = list() //List of Active disease in all mobs; purely for quick referencing.
	var/list/diseases
	var/list/archive_diseases = list()


/datum/controller/subsystem/disease/Initialize()
	if(!diseases)
		diseases = subtypesof(/datum/disease)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/disease/stat_entry(msg)
	msg = "P:[length(active_diseases)]"
	return ..()
