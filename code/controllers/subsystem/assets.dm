var/datum/subsystem/assets/SSasset

/datum/subsystem/assets
	name = "Assets"
	init_order = -3
	flags = SS_NO_FIRE
	var/list/cache = list()

/datum/subsystem/assets/New()
	NEW_SS_GLOBAL(SSasset)

/datum/subsystem/assets/Initialize(timeofday)
	for(var/type in typesof(/datum/asset) - list(/datum/asset, /datum/asset/simple))
		var/datum/asset/A = new type()
		A.register()

	for(var/client/C in clients)
		GiveFilesToClient(C)
	..()

/datum/subsystem/assets/proc/GiveFilesToClient(client/C)
	set waitfor = 0
	sleep(10)	// Doing this to a client too soon after they've connected can cause issues, also the proc we call sleeps.
	getFilesSlow(C, cache, FALSE)