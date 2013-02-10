/var/global/spacevines_spawned = 0

//not working: wait for fix in TG code

/datum/event/spacevine
	oneShot			= 1

/datum/event/spacevine/start()
	spacevine_infestation()
	spacevines_spawned = 1
