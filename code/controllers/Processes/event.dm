var/global/list/events = list()

/datum/controller/process/event
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/event/setup()
	name = "event"

/datum/controller/process/event/doWork()
	for(var/e in events)
		e:process()

/datum/controller/process/event/onFinish()
	checkEvent()
