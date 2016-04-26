/datum/controller/process/nanoui
	schedule_interval = 41 // every 2 seconds

/datum/controller/process/nanoui/setup()
	name = "nanoui"

/datum/controller/process/nanoui/doWork()
	for(var/p in nanomanager.processing_uis)
		if(p)
			p:process()
			scheck()
			continue
		nanomanager.processing_uis -= p
