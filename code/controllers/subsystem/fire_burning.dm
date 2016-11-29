var/datum/subsystem/fire_burning/SSfire_burning

/datum/subsystem/fire_burning
	name = "Fire Burning"
	priority = 40
	flags = SS_NO_INIT|SS_BACKGROUND

	var/list/currentrun = list()
	var/list/processing = list()

/datum/subsystem/fire_burning/New()
	NEW_SS_GLOBAL(SSfire_burning)


/datum/subsystem/fire_burning/stat_entry()
	..("P:[processing.len]")


/datum/subsystem/fire_burning/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/obj/O = currentrun[currentrun.len]
		currentrun.len--
		if (!O || qdeleted(O))
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

