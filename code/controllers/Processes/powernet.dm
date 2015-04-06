var/global/list/datum/powernet/powernets = list() //Holds all powernet datums in use or pooled
var/global/list/cable_list = list() //Index for all cables, so that powernets don't have to look through the entire world all the time

/datum/controller/process/powernet/setup()
	name = "powernet"
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/powernet/doWork()

	for(var/obj/structure/cable/PC in cable_list)
		if(PC.build_status)
			PC.rebuild_from() //Does a powernet need rebuild? Lets do it!

	for(var/datum/powernet/powerNetwork in powernets)
		if(istype(powerNetwork) && !powerNetwork.disposed)
			powerNetwork.reset()
			scheck()
			continue
		powernets.Remove(powerNetwork)