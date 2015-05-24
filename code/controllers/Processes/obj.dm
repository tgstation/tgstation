var/global/list/object_profiling = list()
var/global/list/processing_objects = list()

/datum/controller/process/obj
	var/tmp/datum/updateQueue/updateQueueInstance
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/obj/setup()
	name = "obj"
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
