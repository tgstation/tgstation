var/global/list/active_diseases = list()

/datum/controller/process/disease
	var/tmp/datum/updateQueue/updateQueueInstance
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/disease/setup()
	name = "disease"
	updateQueueInstance = new

/datum/controller/process/disease/doWork()
	updateQueueInstance.init(active_diseases, "process")
	updateQueueInstance.Run()
