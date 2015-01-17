/datum/controller/process/nanoui
	var/tmp/datum/updateQueue/updateQueueInstance

/datum/controller/process/nanoui/setup()
	name = "nanoui"
	schedule_interval = 20 // every 2 seconds
	updateQueueInstance = new

/datum/controller/process/nanoui/doWork()
	updateQueueInstance.init(nanomanager.processing_uis, "process")
	updateQueueInstance.Run()
