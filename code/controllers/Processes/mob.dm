/datum/controller/process/mob
	var/tmp/datum/updateQueue/updateQueueInstance

/datum/controller/process/mob/setup()
	name = "mob"
	schedule_interval = 20 // every 2 seconds
	updateQueueInstance = new

/datum/controller/process/mob/doWork()
	for(var/i = 1 to mob_list.len)
		if(i > mob_list.len)
			break
		var/mob/living/L = mob_list[i]
		if(L)
			if(L.Life() == PROCESS_KILL)
				mob_list.Remove(L)
		else
			if(i+1 > mob_list.len)
				mob_list.len--
			else
				mob_list.Cut(i,i+1)

		scheck()
	//updateQueueInstance.init(mob_list, "Life")
	//updateQueueInstance.Run()
