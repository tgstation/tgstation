var/datum/subsystem/nano/SSnano

/datum/subsystem/nano
	name = "NanoUI"
	can_fire = 1
	wait = 10
	priority = 16

	var/list/open_uis = list() // A list of open NanoUIs, grouped by src_object and ui_key.
	var/list/processing_uis = list() // A list of processing NanoUIs, not grouped.


/datum/subsystem/nano/New()
	NEW_SS_GLOBAL(SSnano) // Register the subsystem.


/datum/subsystem/nano/stat_entry()
	..("O:[open_uis.len]|P:[processing_uis.len]") // Show how many interfaces we have open/are processing.


/datum/subsystem/nano/fire() // Process UIs.
	for(var/datum/nanoui/ui in processing_uis)
		if(ui && ui.src_object && ui.user)
			ui.process()
			continue
		processing_uis.Remove(ui)
