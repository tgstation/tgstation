/datum/controller/process/disease
	var/tmp/datum/updateQueue/updateQueueInstance

/datum/controller/process/disease/setup()
	name = "disease"
	schedule_interval = 20 // every 2 seconds
	updateQueueInstance = new

/datum/controller/process/disease/doWork()
	updateQueueInstance.init(active_diseases, "process")
	updateQueueInstance.Run()
