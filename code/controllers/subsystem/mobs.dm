var/datum/subsystem/mobs/SSmob

/datum/subsystem/mobs
	name = "Mobs"
	priority = 4


/datum/subsystem/mobs/New()
	NEW_SS_GLOBAL(SSmob)


/datum/subsystem/mobs/stat_entry()
	stat(name, "[round(cost,0.001)]ds (CPU:[round(cpu,1)]%) [mob_list.len]")


/datum/subsystem/mobs/fire()
	var/seconds = wait * 0.1
	for(var/mob/m in mob_list)
		if(m)
			m.Life(seconds)
			continue
		mob_list.Remove(m)