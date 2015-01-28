var/datum/subsystem/diseases/SSdisease

/datum/subsystem/diseases
	name = "Diseases"
	priority = 7

	var/list/processing = list()

/datum/subsystem/diseases/New()
	NEW_SS_GLOBAL(SSdisease)


/datum/subsystem/diseases/fire()
	var/i=1
	for(var/datum/disease/d in processing)
		if(d)
			d.process()
			++i
			continue
		processing.Cut(i,i+1)
