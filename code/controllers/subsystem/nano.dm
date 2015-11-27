var/datum/subsystem/nano/SSnano

/datum/subsystem/nano
	name = "NanoUI"
	can_fire = 1
	wait = 10
	priority = 16

	var/list/open_uis = list() // A list of open NanoUIs, grouped by src_object and ui_key.
	var/list/processing_uis = list() // A list of processing NanoUIs, not grouped.

	var/list/resource_files // A list of asset files to be send to clients.


/datum/subsystem/nano/New()
	NEW_SS_GLOBAL(SSnano) // Register the subsystem.

	resource_files = get_resources() // Populate the list of resource files.


/datum/subsystem/nano/stat_entry()
	..("P:[processing_uis.len]") // Show how many interfaces we are processing.


/datum/subsystem/nano/fire() // Process UIs.
	for(var/thing in SSnano.processing_uis)
		if(thing)
			var/datum/nanoui/ui = thing
			if(ui.src_object && ui.user)
				ui.process()
				continue
		processing_uis.Remove(thing)
