var/datum/subsystem/nano/SSnano

/datum/subsystem/nano
	name = "NanoUI"
	wait = 5
	priority = 16
	display = 6

	can_fire = 1 // This needs to fire before round start.

	var/list/open_uis = list() // A list of open NanoUIs, grouped by src_object and ui_key.
	var/list/processing_uis = list() // A list of processing NanoUIs, not grouped.


/datum/subsystem/nano/New()
	NEW_SS_GLOBAL(SSnano)

/datum/subsystem/nano/stat_entry()
	..("O:[open_uis.len]|P:[processing_uis.len]") // Show how many interfaces we have open/are processing.

/datum/subsystem/nano/fire() // Process UIs.
	for(var/thing in processing_uis)
		var/datum/nanoui/ui = thing
		if(ui && ui.src_object && ui.user)
			ui.process()
			continue
		processing_uis.Remove(ui)
