var/datum/subsystem/tgui/SStgui

/datum/subsystem/tgui
	name = "tgui"
	wait = 10
	priority = 16
	display = 6

	can_fire = 1 // This needs to fire before round start.

	var/list/open_uis = list() // A list of open UIs, grouped by src_object and ui_key.
	var/list/processing_uis = list() // A list of processing UIs, not grouped.
	var/basehtml // The HTML template used by new UIs; minus initial data.


/datum/subsystem/tgui/New()
	basehtml = file2text('tgui/tgui.html') // Read the HTML from disk.

	NEW_SS_GLOBAL(SStgui)

/datum/subsystem/tgui/stat_entry()
	..("P:[processing_uis.len]") // Show how many interfaces we have open/are processing.

/datum/subsystem/tgui/fire() // Process UIs.
	for(var/thing in processing_uis)
		var/datum/tgui/ui = thing
		if(ui && ui.user && ui.src_object)
			ui.process()
			continue
		processing_uis.Remove(ui)
