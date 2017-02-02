
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
	var/mc_compensation = TRUE
	var/tickdrift_compensation = TRUE
	var/mc_tickdrift_last = 0

/datum/subsystem/projectiles/New()
	NEW_SS_GLOBAL(SSprojectiles)

/datum/subsystem/projectiles/Destroy()
	for(var/obj/item/projectile/P in processing)
		qdel(P)
	. = ..()

/datum/subsystem/projectiles/fire(resumed = FALSE)
	if(!resumed)
		currentrun = processing.Copy()
	var/tickdrift_compensate = 0
	var/mc_compensate = 1
	if(mc_compensation)
		mc_compensate = Master.processing
	if(tickdrift_compensation)
		tickdrift_compensate = Master.tickdrift - mc_tickdrift_last
		tickdrift_compensate *= mc_compensate
	while(length(currentrun))
		var/obj/item/projectile/P = currentrun[currentrun.len]
		if(wait_compensation)
			P.process((wait*tick_multiplier*mc_compensate) + tickdrift_compensate)
		else
			P.process((tick_multiplier*mc_compensate) + tickdrift_compensate)
		currentrun.len--
		if(!P)
			processing -= P
		if(MC_TICK_CHECK)
			return
	mc_tickdrift_last = Master.tickdrift
	currentrun = null
