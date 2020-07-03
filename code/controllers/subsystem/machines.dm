SUBSYSTEM_DEF(machines)
	name = "Machines"
	init_order = INIT_ORDER_MACHINES
	flags = SS_KEEP_TIMING
	var/list/processing = list()
	var/list/currentrun = list()
	var/list/powernets = list()
	var/powernets_nulls = 0
	var/list/recycled_powernets = list()
	var/list/powernet_rebuild_queue = list()

// at this we really need to reindex the powernets
// we can also use this as an indicator of massive damage
// to the cable network
#define POWERNET_REINDEX_HIGH_MARK 50
// This is all for debugging to see whats going on in the nets

/datum/controller/subsystem/machines/proc/reindex_powernets()
	var/list/reindexed = list()
	var/datum/powernet/N
	var/i
	for(i=1; i < recycled_powernets.len; i++)
		N = recycled_powernets[i]
		if(N)
			reindexed += N
			N.number = reindexed.len
			recycled_powernets[i] = null // this needed?
	recycled_powernets = reindexed

/datum/controller/subsystem/machines/proc/aquire_powernet()
	var/datum/powernet/N
	if(recycled_powernets.len > 0)
		N = recycled_powernets[recycled_powernets.len--]
	else
		N = new/datum/powernet
	powernets += N
	N.number = powernets.len
	return N

/datum/controller/subsystem/machines/proc/release_powernet(datum/powernet/N)
	ASSERT(N.consumers.len == 0)
	ASSERT(N.producers.len == 0)
	ASSERT(N.cables.len == 0)
	powernets[N.number] = null  	/// We just null it
	powernets_nulls++
	N.number = 0
	N.load = 0
	N.newavail = 0
	N.avail = 0
	N.viewavail = 0
	N.viewload = 0
	N.netexcess = 0
	N.delayedload = 0
	recycled_powernets += N
	if(powernets_nulls >= POWERNET_REINDEX_HIGH_MARK)
		reindex_powernets()


/datum/controller/subsystem/machines/Initialize()
	makepowernets()
	fire()
	return ..()

/datum/controller/subsystem/machines/proc/makepowernets()
	for(var/datum/powernet/PN in powernets)
		qdel(PN)
	powernets.Cut()

	for(var/obj/structure/cable/PC in GLOB.cable_list)
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)

/datum/controller/subsystem/machines/stat_entry()
	..("M:[processing.len]|PN:[powernets.len]")


/datum/controller/subsystem/machines/fire(resumed = 0)
	if (!resumed)
		for(var/datum/powernet/Powernet in powernets)
			Powernet.reset() //reset the power state.
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	var/seconds = wait * 0.1
	while(currentrun.len)
		var/obj/machinery/thing = currentrun[currentrun.len]
		currentrun.len--
		if(!QDELETED(thing) && thing.process(seconds) != PROCESS_KILL)
			if(thing.use_power)
				thing.auto_use_power() //add back the power state
		else
			processing -= thing
			if (!QDELETED(thing))
				thing.datum_flags &= ~DF_ISPROCESSING
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/machines/proc/setup_template_powernets(list/cables)
	for(var/A in cables)
		var/obj/structure/cable/PC = A
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)

/datum/controller/subsystem/machines/Recover()
	if (istype(SSmachines.processing))
		processing = SSmachines.processing
	if (istype(SSmachines.powernets))
		powernets = SSmachines.powernets
