var/global/list/events = list()

/datum/controller/process/event
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/event/setup()
	name = "event"

/datum/controller/process/event/doWork()
	for(var/e in events)
		if(e)
			e:process()
			scheck()
			continue
		events -= e

/datum/controller/process/event/onFinish()
	checkEvent()
