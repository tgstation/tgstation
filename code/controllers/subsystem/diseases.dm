GLOBAL_REAL(SSdisease, /datum/controller/subsystem/diseases)

/datum/controller/subsystem/diseases
	name = "Diseases"
	flags = SS_KEEP_TIMING|SS_NO_INIT

	var/list/currentrun = list()
	var/list/processing = list()

	var/list/diseases
	var/list/archive_diseases = list()

	var/static/list/list_symptoms = subtypesof(/datum/symptom)

/datum/controller/subsystem/diseases/New()
	NEW_SS_GLOBAL(SSdisease)
	if(!diseases)
		diseases = subtypesof(/datum/disease)

/datum/controller/subsystem/diseases/Recover()
	currentrun = SSdisease.currentrun
	processing = SSdisease.processing
	diseases = SSdisease.diseases
	archive_diseases = SSdisease.archive_diseases

/datum/controller/subsystem/diseases/stat_entry(msg)
	..("P:[processing.len]")

/datum/controller/subsystem/diseases/fire(resumed = 0)
	if(!resumed)
		src.currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/thing = currentrun[currentrun.len]
		currentrun.len--
		if(thing)
			thing.process()
		else
			processing.Remove(thing)
		if (MC_TICK_CHECK)
			return
