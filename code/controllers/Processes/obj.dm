var/global/list/object_profiling = list()
/datum/controller/process/obj
	var/tmp/datum/updateQueue/updateQueueInstance

/datum/controller/process/obj/setup()
	name = "obj"
	schedule_interval = 20 // every 2 seconds
	updateQueueInstance = new

/datum/controller/process/obj/started()
	..()
	if(!updateQueueInstance)
		if(!processing_objects)
			processing_objects = list()
		else if(processing_objects.len)
			updateQueueInstance = new

/datum/controller/process/obj/doWork()
	if(updateQueueInstance)
		updateQueueInstance.init(processing_objects, "process")
		updateQueueInstance.Run()
