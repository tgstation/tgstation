var/datum/subsystem/mobs/SSmob

/datum/subsystem/mobs
	name = "Mobs"
	priority = 4
	display = 4

	var/list/currentrun = list()

/datum/subsystem/mobs/New()
	NEW_SS_GLOBAL(SSmob)


/datum/subsystem/mobs/stat_entry()
	..("P:[mob_list.len]")


/datum/subsystem/mobs/fire(resumed = 0)
	var/seconds = wait * 0.1
	if (!resumed)
		src.currentrun = mob_list.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/mob/M = currentrun[1]
		currentrun.Cut(1, 2)
		if(M)
			M.Life(seconds)
		else
			mob_list.Remove(M)
		if (MC_TICK_CHECK)
			return