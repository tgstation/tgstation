var/datum/subsystem/pool/SSpool

/datum/subsystem/pool
	name = "Pool"
	init_order = 20
	flags = SS_BACKGROUND | SS_FIRE_IN_LOBBY
	var/list/global_pool
	var/list/pool_levels = list()
	var/sum = 0

	var/list/maintained_types = list(
		/obj/item/stack/tile/plasteel = 100
	)

	var/list/stats_placed_in_pool = list()
	var/list/stats_pooled_or_newed = list()
	var/list/stats_reused = list()
	var/list/stats_created_new = list()

/datum/subsystem/pool/New()
	NEW_SS_GLOBAL(SSpool)

/datum/subsystem/pool/Initialize(timeofday)
	global_pool = GlobalPool

/datum/subsystem/pool/stat_entry(msg)
	if(global_pool)
		msg += "Types: [global_pool.len]|Total Pooled Objects: [sum]"
	else
		msg += "NULL POOL"
	..(msg)

/datum/subsystem/pool/fire()
	sum = 0
	for(var/type in global_pool + maintained_types)
		var/list/L = global_pool[type]
		var/required_number = maintained_types[type] || 0

		// Update pool levels and tracker
		var/amount = 0
		if(L)
			amount = L.len
		sum += amount

		// why yes, just inflate the pool at one item per tick
		if(amount < required_number)
			var/diver = new type
			qdel(diver)
