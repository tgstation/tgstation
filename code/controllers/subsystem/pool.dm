var/datum/subsystem/pool/SSpool

/datum/subsystem/pool
	name = "Pool"
	init_order = 20
	flags = SS_NO_FIRE
	var/list/global_pool

/datum/subsystem/pool/New()
	NEW_SS_GLOBAL(SSpool)

/datum/subsystem/pool/Initialize(timeofday)
	global_pool = GlobalPool
	..()

/datum/subsystem/pool/stat_entry(msg)
	if(global_pool)
		msg += "Types: [global_pool.len]"
	else
		msg += "NULL POOL"
	..(msg)
