/datum/controller/process/obj
	var/tmp/datum/updateQueue/updateQueueInstance

/datum/controller/process/obj/setup()
	name = "obj"
	schedule_interval = 20 // every 2 seconds
	updateQueueInstance = new

/datum/controller/process/obj/doWork()
	updateQueueInstance.init(processing_objects, "process")
	updateQueueInstance.Run()
