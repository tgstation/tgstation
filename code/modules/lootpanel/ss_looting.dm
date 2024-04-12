
/// Queues image generation for search objects without icons
SUBSYSTEM_DEF(looting)
	name = "Loot Icon Generation"
	init_order = INIT_ORDER_LOOT
	priority = FIRE_PRIORITY_PROCESS
	wait = 0.5 SECONDS
	/// The list of search objects needing icons
	var/list/datum/search_object/backlog = list()
	/// Cached contents currently processing
	var/list/datum/search_object/processing = list()


/datum/controller/subsystem/looting/stat_entry(msg)
	msg = "P:[length(backlog)]"
	return ..()


/datum/controller/subsystem/looting/fire(resumed)
	if(!resumed)
		processing = backlog.Copy()

	processing = backlog
	backlog = list()
	
	while(length(processing))
		var/datum/search_object/item = processing[length(processing)]
		if(QDELETED(item))
			processing.len--
			continue

		if(!item.generate_icon())
			qdel(item)

		processing.len--


/// Adds the list of contents that require icons to the backlog
/datum/controller/subsystem/looting/proc/add_contents(list/contents)
	for(var/datum/search_object/item in contents)
		if(!item.icon)
			backlog += item
