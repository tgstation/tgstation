//Mob_List located in global_lists.dm

/datum/controller/process/mob
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/mob/setup()
	name = "mob"

/datum/controller/process/mob/started()
	..()
	if(!mob_list)
		mob_list = list()

/datum/controller/process/mob/doWork()
	if (mob_list)
		for(var/m in mob_list)
			m:Life()
			scheck()