SUBSYSTEM_DEF(turf_fire)
	name = "Turf Fire"
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 2 SECONDS
	var/list/fires = list()

/datum/controller/subsystem/turf_fire/fire()
	for(var/obj/effect/abstract/turf_fire/fire as anything in fires)
		fire.process()
