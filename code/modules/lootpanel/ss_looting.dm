
/// Queues image generation for search objects without icons
SUBSYSTEM_DEF(looting)
	name = "Loot Icon Generation"
	flags = SS_NO_INIT
	priority = FIRE_PRIORITY_PROCESS
	runlevels = RUNLEVEL_LOBBY|RUNLEVELS_DEFAULT
	wait = 0.5 SECONDS
	/// Backlog of items. Gets put into processing
	var/list/datum/lootpanel/backlog = list()
	/// Actively processing items
	var/list/datum/lootpanel/processing = list()


/datum/controller/subsystem/looting/stat_entry(msg)
	msg = "P:[length(backlog)]"
	return ..()


/datum/controller/subsystem/looting/fire(resumed)
	if(!length(backlog))
		return

	if(!resumed)
		processing = backlog
		backlog = list()

	while(length(processing))
		var/datum/lootpanel/panel = processing[length(processing)]
		if(QDELETED(panel) || !length(panel.to_image))
			processing.len--
			continue

		if(!panel.process_images())
			backlog += panel

		if(MC_TICK_CHECK)
			return

		processing.len--
