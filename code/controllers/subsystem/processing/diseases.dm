var/datum/subsystem/processing/diseases/SSdisease

/datum/subsystem/processing/diseases
	name = "Diseases"
	flags = SS_KEEP_TIMING|SS_NO_INIT
	stat_tag = "D"

/datum/subsystem/processing/diseases/New()
	NEW_SS_GLOBAL(SSdisease)

/datum/subsystem/processing/diseases/Recover()
	..(SSdisease)

/datum/subsystem/processing/diseases/proc/RefreshDiseases()
	for(var/I in processing_list)
		var/datum/disease/advance/D = I
		D.Refresh()

/datum/subsystem/processing/diseases/proc/CureAll()
	for(var/I in processing_list)
		var/datum/disease/advance/D = I
		D.cure()