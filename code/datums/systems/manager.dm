// See initialization order in /code/game/world.dm
GLOBAL_REAL(SysMgr, /datum/system_manager)


/**
 * Initializes all data systems and keeps track of them.
 */
/datum/system_manager
	/// List of managed data systems, post initialization.
	var/list/datum/system/managed = list()


/datum/system_manager/New()
	init_subtypes(/datum/system, managed)
