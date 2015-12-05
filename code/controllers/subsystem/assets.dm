var/datum/subsystem/assets/SSasset

/datum/subsystem/assets
	name = "Assets"
	priority = -3

	var/list/cache = list()

/datum/subsystem/assets/New()
	NEW_SS_GLOBAL(SSasset)

/datum/subsystem/assets/Initialize(timeofday, zlevel)
	if (zlevel)
		return ..()
	for(var/type in typesof(/datum/asset) - list(/datum/asset, /datum/asset/simple))
		var/datum/asset/A = new type()
		A.register()

	for(var/client/C in clients)
		// Doing this to a client too soon after they've connected can cause issues, also the proc we call sleeps.
		spawn(10)
			getFilesSlow(C, cache, FALSE)
	..()
