var/global/list/events = list()

/datum/controller/process/event
	var/tmp/datum/updateQueue/updateQueueInstance
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/event/setup()
	name = "event"
	updateQueueInstance = new

/datum/controller/process/event/doWork()
	updateQueueInstance.init(events, "process")
	updateQueueInstance.Run()

/datum/controller/process/event/onFinish()
	checkEvent()
