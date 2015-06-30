var/datum/subsystem/mobs/SSmob

/datum/subsystem/mobs
	name = "Mobs"
	priority = 4


/datum/subsystem/mobs/New()
	NEW_SS_GLOBAL(SSmob)


/datum/subsystem/mobs/stat_entry()
	..("P:[mob_list.len]")


/datum/subsystem/mobs/fire()
	var/seconds = wait * 0.1
	for(var/thing in mob_list)
		if(thing)
			thing:Life(seconds)
			continue
		mob_list.Remove(thing)

/datum/subsystem/mobs/AfterInitialize()
	set_clownplanet_mob_ai(AI_OFF)



/datum/subsystem/mobs/proc/set_clownplanet_mob_ai(var/AIstatus)
	for(var/mob/living/simple_animal/hostile/M in living_mob_list)
		if(M.z == ZLEVEL_CLOWN)	//Suspend mob AI in clown planet
			M.AIStatus = AIstatus