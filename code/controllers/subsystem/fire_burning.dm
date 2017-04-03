SUBSYSTEM_DEF(fire_burning)
	name = "Fire Burning"
	priority = 40
	flags = SS_NO_INIT|SS_BACKGROUND

	var/list/currentrun = list()
	var/list/processing = list()

/datum/controller/subsystem/fire_burning/stat_entry()
	..("P:[processing.len]")


/datum/controller/subsystem/fire_burning/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/obj/O = currentrun[currentrun.len]
		currentrun.len--
		if (!O || QDELETED(O))
			processing -= O
			if (MC_TICK_CHECK)
				return
			continue

		if(O.resistance_flags & ON_FIRE)
			O.take_damage(20, BURN, "fire", 0)
		else
			processing -= O

		if (MC_TICK_CHECK)
			return

