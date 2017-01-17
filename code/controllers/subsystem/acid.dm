var/datum/subsystem/acid/SSacid

/datum/subsystem/acid
	name = "Acid"
	priority = 40
	flags = SS_NO_INIT|SS_BACKGROUND

	var/list/currentrun = list()
	var/list/processing = list()

/datum/subsystem/acid/New()
	NEW_SS_GLOBAL(SSacid)


/datum/subsystem/acid/stat_entry()
	..("P:[processing.len]")


/datum/subsystem/acid/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while (currentrun.len)
		var/obj/O = currentrun[currentrun.len]
		currentrun.len--
		if (!O || qdeleted(O))
			processing -= O
			if (MC_TICK_CHECK)
				return
			continue

		if(O.acid_level && O.acid_processing())
		else
			O.overlays -= acid_overlay
			O.priority_overlays -= acid_overlay
			processing -= O

		if (MC_TICK_CHECK)
			return
