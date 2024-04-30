// See initialization order in /code/game/world.dm
GLOBAL_REAL(SysMgr, /datum/system_manager)


/**
 * Initializes all data systems and keeps track of them.
 */
/datum/system_manager
	/// List of managed data systems, post initialization.
	var/list/datum/system/managed = list()


/datum/system_manager/New()
	var/list/datasystems = init_subtypes(/datum/system)
	for(var/datum/system/datasystem as anything in datasystems)
		if(datasystem.system_flags & DS_FLAG_REQUIRES_INITIALIZATION)
			datasystem.Initialize()

		managed += datasystem
