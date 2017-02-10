var/datum/subsystem/processing/orbit/SSorbit

/datum/subsystem/processing/orbit
	name = "Orbits"
	priority = 35
	wait = 2
	flags = SS_NO_INIT|SS_TICKER

	stat_tag = "Orb"

/datum/subsystem/processing/orbit/New()
	NEW_SS_GLOBAL(SSorbit)

/datum/subsystem/processing/Recover()
	..(SSorbit)

/datum/orbit/process()
	if (!orbiter)
		qdel(src)
		return
	if (lastprocess >= world.time) //we already checked recently
		return
	var/targetloc = get_turf(orbiting)
	if (targetloc != lastloc || orbiter.loc != targetloc)
		Check(targetloc)


