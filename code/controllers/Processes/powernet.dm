/datum/controller/process/powernet/setup()
	name = "powernet"
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/powernet/doWork()
	for(var/datum/powernet/powerNetwork in powernets)
		if(istype(powerNetwork) && !powerNetwork.disposed)
			powerNetwork.reset()
			scheck()
			continue

		powernets.Remove(powerNetwork)
