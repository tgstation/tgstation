
var/datum/subsystem/projectiles/SSprojectiles

/datum/subsystem/projectiles
	name = "Projectiles"
	wait = 1
	priority = 25
	flags = SS_TICKER	//|SS_KEEP_TIMING	- Do I need this..?
	var/list/processing = list()
	var/list/currentrun = list()
	var/wait_compensation = TRUE
	var/tick_multiplier = 1

/datum/subsystem/projectiles/New()
	NEW_SS_GLOBAL(SSprojectiles)

/datum/subsystem/projectiles/Destroy()
	for(var/obj/item/projectile/P in processing)
		qdel(P)
	. = ..()

/datum/subsystem/projectiles/fire(resumed = FALSE)
	if(!resumed)
		currentrun = processing.Copy()
	while(length(currentrun))
		var/obj/item/projectile/P = currentrun[currentrun.len]
		if(wait_compensation)
			P.process(wait*tick_multiplier)
		else
			P.process(tick_multiplier)
		currentrun.len--
		if(!P)
			processing -= P
		if(MC_TICK_CHECK)
			return
	currentrun = null
