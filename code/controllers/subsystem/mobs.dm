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