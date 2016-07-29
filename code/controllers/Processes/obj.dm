var/global/list/object_profiling = list()
var/global/list/processing_objects = list()

/datum/controller/process/obj
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/obj/setup()
	name = "obj"

/datum/controller/process/obj/started()
	..()
	if (!processing_objects)
		processing_objects = list()

/datum/controller/process/obj/doWork()
	if(processing_objects)
		for(var/atom/o in processing_objects)
			if(o)
				if(o.timestopped) continue
				o:process()
				scheck()
				continue
			processing_objects -= o
