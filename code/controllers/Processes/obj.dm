var/global/list/object_profiling = list()
/datum/controller/process/obj
	var/tmp/datum/updateQueue/updateQueueInstance

/datum/controller/process/obj/setup()
	name = "obj"
	schedule_interval = 20 // every 2 seconds
	updateQueueInstance = new

/datum/controller/process/obj/doWork()
	for(var/i = 1 to processing_objects.len)
		if(i > processing_objects.len)
			break
		#ifdef PROFILE_MACHINES
		var/time_start = world.timeofday
		#endif
		var/obj/O = processing_objects[i]
		if(O)
			O.process()
			#ifdef PROFILE_MACHINES
			var/time_end = world.timeofday
			if(O)
				if(!("[O.type]" in object_profiling))
					object_profiling["[O.type]"] = 0
				object_profiling["[O.type]"] += (time_end - time_start)
			else
				processing_objects.Cut(i,i+1)
			#endif
		else
			processing_objects.Cut(i,i+1)

		scheck()
	//updateQueueInstance.init(processing_objects, "process")
	//updateQueueInstance.Run()
