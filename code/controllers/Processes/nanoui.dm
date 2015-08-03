/datum/controller/process/nanoui
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/nanoui/setup()
	name = "nanoui"

/datum/controller/process/nanoui/doWork()
	for(var/p in nanomanager.processing_uis)
		p:process()